#!/usr/bin/env bash
# One-time Planka v1 -> v2 migration.
#
# Run only after Planka v1 has been updated to at least 1.26.2 and after the
# v2 image and /app/data mount have been rendered by Ansible. The script makes
# independent backups of the Planka database and legacy file storage, then
# performs the upstream database and file-layout migration.
#
# Usage:
#   sudo ./migrate_planka_v1_to_v2.sh --execute

set -Eeuo pipefail
umask 077

planka_base_path="${PLANKA_BASE_PATH:-/datafolder/homeserver/services/planka}"
legacy_data_path="${planka_base_path}/config"
v2_data_path="${planka_base_path}/data"
background_images_path="${planka_base_path}/migration-background-images"
environment_file="${planka_base_path}/planka.env"
backup_root="${planka_base_path}/migration-backups"
postgres_container="${POSTGRES_CONTAINER:-postgres}"
planka_service="${PLANKA_SERVICE:-planka.service}"
planka_v2_image="${PLANKA_V2_IMAGE:-ghcr.io/plankanban/planka:2.2.1}"
planka_upgrade_image="${PLANKA_UPGRADE_IMAGE:-ghcr.io/plankanban/planka:2.0.0}"
planka_v1_image="${PLANKA_V1_IMAGE:-lscr.io/linuxserver/planka:1.26.2}"
docker_network="${PLANKA_DOCKER_NETWORK:-nginx-proxy}"
database_name="${PLANKA_DATABASE_NAME:-planka}"

migration_environment_file=""

cleanup() {
  if [[ -n "${migration_environment_file}" ]]; then
    rm -f -- "${migration_environment_file}"
  fi
}

trap cleanup EXIT

if [[ "${1:-}" != "--execute" || $# -ne 1 ]]; then
  echo "Refusing to run without the explicit --execute flag." >&2
  echo "Usage: sudo $0 --execute" >&2
  exit 2
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this migration as root." >&2
  exit 1
fi

for required_command in docker systemctl tar gzip date find realpath mktemp; do
  command -v "${required_command}" >/dev/null || {
    echo "Required command is unavailable: ${required_command}" >&2
    exit 1
  }
done

for required_path in "${planka_base_path}" "${legacy_data_path}"; do
  [[ -d "${required_path}" ]] || {
    echo "Required directory is missing: ${required_path}" >&2
    exit 1
  }
done

planka_base_path="$(realpath -e -- "${planka_base_path}")"
legacy_data_path="$(realpath -e -- "${legacy_data_path}")"

if [[ "${planka_base_path}" != /datafolder/*/services/planka ]]; then
  echo "Refusing an unexpected Planka base path: ${planka_base_path}" >&2
  exit 1
fi

if [[ "${legacy_data_path}" != "${planka_base_path}/config" ]]; then
  echo "Refusing an unexpected legacy data path: ${legacy_data_path}" >&2
  exit 1
fi

[[ -f "${environment_file}" ]] || {
  echo "Missing ${environment_file}. Render the v2 Planka role first, without starting it." >&2
  exit 1
}

# systemd's EnvironmentFile parser removes surrounding quotes, while Docker's
# --env-file preserves them. Produce a minimal, root-only env file so the
# temporary migration containers receive the same values as the systemd unit.
migration_environment_file="$(mktemp)"
while IFS= read -r line; do
  case "${line}" in
    BASE_URL=*|DATABASE_URL=*|SECRET_KEY=*|TRUST_PROXY=*)
      key="${line%%=*}"
      value="${line#*=}"
      if [[ ${#value} -ge 2 && "${value:0:1}" == '"' && "${value: -1}" == '"' ]]; then
        value="${value:1:-1}"
      fi
      printf '%s=%s\n' "${key}" "${value}" >> "${migration_environment_file}"
      ;;
  esac
done < "${environment_file}"

for required_variable in BASE_URL DATABASE_URL SECRET_KEY TRUST_PROXY; do
  grep -q "^${required_variable}=." "${migration_environment_file}" || {
    echo "Missing ${required_variable} in ${environment_file}" >&2
    exit 1
  }
done

docker inspect "${postgres_container}" >/dev/null 2>&1 || {
  echo "PostgreSQL container is unavailable: ${postgres_container}" >&2
  exit 1
}

if ! docker network inspect "${docker_network}" >/dev/null 2>&1; then
  echo "Docker network is unavailable: ${docker_network}" >&2
  exit 1
fi

if ! docker image inspect "${planka_v2_image}" >/dev/null 2>&1; then
  echo "Pull the target Planka v2 image before running this script: ${planka_v2_image}" >&2
  exit 1
fi

for legacy_directory in user-avatars project-background-images attachments; do
  [[ -d "${legacy_data_path}/${legacy_directory}" ]] || {
    echo "Missing legacy Planka directory: ${legacy_data_path}/${legacy_directory}" >&2
    exit 1
  }
done

if [[ -e "${v2_data_path}/.planka-v2-migration-complete" ]]; then
  echo "The v2 migration marker already exists: ${v2_data_path}/.planka-v2-migration-complete" >&2
  exit 1
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_path="${backup_root}/${timestamp}"
mkdir -p -- "${backup_path}" "${v2_data_path}" "${background_images_path}"
chmod 0700 "${backup_root}" "${backup_path}"

echo "Stopping ${planka_service}..."
systemctl stop "${planka_service}"

echo "Backing up the Planka database..."
docker exec "${postgres_container}" sh -c \
  'PGPASSWORD="$POSTGRES_PASSWORD" exec pg_dump -U "$POSTGRES_USER" -d "$1"' \
  -- "${database_name}" | gzip -c > "${backup_path}/planka.sql.gz"

echo "Backing up legacy Planka files..."
tar -C "${legacy_data_path}" -czf "${backup_path}/legacy-files.tar.gz" \
  user-avatars project-background-images attachments

gzip -t "${backup_path}/planka.sql.gz"
tar -tzf "${backup_path}/legacy-files.tar.gz" >/dev/null

echo "Starting the required Planka 1.26.2 intermediate upgrade..."
docker pull "${planka_v1_image}"
docker run -d --rm --name planka-v1-preupgrade \
  --network "${docker_network}" \
  --env-file "${migration_environment_file}" \
  --env PUID=1000 \
  --env PGID=1000 \
  -v "${legacy_data_path}:/config" \
  "${planka_v1_image}" >/dev/null

for attempt in $(seq 1 60); do
  if docker inspect -f '{{.State.Running}}' planka-v1-preupgrade 2>/dev/null | grep -qx true; then
    sleep 1
    continue
  fi
  echo "Planka 1.26.2 exited unexpectedly:" >&2
  docker logs planka-v1-preupgrade 2>&1 || true
  exit 1
done

docker stop planka-v1-preupgrade >/dev/null

echo "Preparing the v2 background-images storage..."
docker run --rm --user root \
  -v "${legacy_data_path}/project-background-images:/legacy:ro" \
  -v "${background_images_path}:/background-images" \
  alpine:3.21 sh -ec '
    cp -a /legacy/. /background-images/
    chown -R 1000:1000 /background-images
  '

echo "Upgrading the Planka database schema..."
echo "Using ${planka_upgrade_image} for the v1-to-v2 schema transition..."
docker pull "${planka_upgrade_image}"
docker run --rm \
  --network "${docker_network}" \
  --env-file "${migration_environment_file}" \
  --env NODE_ENV=production \
  -v "${legacy_data_path}/user-avatars:/app/public/user-avatars" \
  -v "${legacy_data_path}/project-background-images:/app/public/project-background-images" \
  -v "${background_images_path}:/app/public/background-images" \
  -v "${legacy_data_path}/attachments:/app/private/attachments" \
  -v "${v2_data_path}:/app/data" \
  "${planka_upgrade_image}" npm run db:upgrade

echo "Copying legacy files into the v2 data layout..."
docker run --rm --user root \
  -v "${legacy_data_path}/user-avatars:/legacy/user-avatars:ro" \
  -v "${background_images_path}:/legacy/background-images:ro" \
  -v "${legacy_data_path}/attachments:/legacy/attachments:ro" \
  -v "${v2_data_path}:/data" \
  alpine:3.21 sh -ec '
    mkdir -p /data/protected /data/private
    cp -a /legacy/user-avatars /data/protected/
    mkdir -p /data/protected/background-images
    cp -a /legacy/background-images/. /data/protected/background-images/
    cp -a /legacy/attachments /data/private/
    chown -R 1000:1000 /data
  '

echo "Applying post-upgrade database migrations..."
docker run --rm \
  --network "${docker_network}" \
  --env-file "${migration_environment_file}" \
  --env NODE_ENV=production \
  -v "${v2_data_path}:/app/data" \
  "${planka_upgrade_image}" npm run db:migrate

touch "${v2_data_path}/.planka-v2-migration-complete"
chmod 0600 "${v2_data_path}/.planka-v2-migration-complete"
systemctl disable "${planka_service}"

echo "Migration completed successfully."
echo "Backups: ${backup_path}"
echo "Planka remains stopped. Apply the v2 Ansible role, then start Planka and verify data before deleting nothing."
