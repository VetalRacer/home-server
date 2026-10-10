#!/usr/bin/env bash
# One-time migration of permissions after changing shared-service identities.
# Usage: sudo ./fix_storage_permissions.sh [share_root] [group] [filebrowser_data_root] [uid:gid]

set -euo pipefail

share_root="${1:-/datafolder/sharefolder}"
share_group="${2:-users}"
filebrowser_data_root="${3:-/datafolder/homeserver/services/filebrowser/data}"
service_owner="${4:-1000:100}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root, for example: sudo $0" >&2
  exit 1
fi

if [[ ! -d "${share_root}" ]]; then
  echo "Share root is not a directory: ${share_root}" >&2
  exit 1
fi

share_root="$(realpath -e -- "${share_root}")"

if [[ "${share_root}" != "/datafolder/sharefolder" && "${share_root}" != /datafolder/sharefolder/* ]]; then
  echo "Refusing to modify a path outside /datafolder/sharefolder: ${share_root}" >&2
  exit 1
fi

if ! getent group "${share_group}" >/dev/null; then
  echo "Group does not exist: ${share_group}" >&2
  exit 1
fi

if [[ ! "${service_owner}" =~ ^[1-9][0-9]*:[1-9][0-9]*$ ]]; then
  echo "Service owner must have the form UID:GID: ${service_owner}" >&2
  exit 1
fi

if [[ ! -d "${filebrowser_data_root}" ]]; then
  echo "FileBrowser data directory is not a directory: ${filebrowser_data_root}" >&2
  exit 1
fi

filebrowser_data_root="$(realpath -e -- "${filebrowser_data_root}")"

if [[ ! "${filebrowser_data_root}" =~ ^/datafolder/[^/]+/services/filebrowser/data$ ]]; then
  echo "Refusing to modify an unexpected FileBrowser data path: ${filebrowser_data_root}" >&2
  exit 1
fi

for filebrowser_state_dir in config database; do
  if [[ ! -d "${filebrowser_data_root}/${filebrowser_state_dir}" ]]; then
    echo "FileBrowser ${filebrowser_state_dir} directory is missing: ${filebrowser_data_root}/${filebrowser_state_dir}" >&2
    exit 1
  fi
done

echo "Updating group access under ${share_root} for group ${share_group}..."

# Do not follow symlinks. Owners and other-user permissions are preserved.
find -P "${share_root}" -exec chgrp "${share_group}" {} +
find -P "${share_root}" -type d -exec chmod g+rwx,g+s {} +
find -P "${share_root}" -type f -exec chmod g+rw {} +

echo "Done. Directories inherit group ${share_group}; existing owners were preserved."

echo "Updating FileBrowser configuration and database ownership to ${service_owner}..."
chown -R --no-dereference "${service_owner}" \
  "${filebrowser_data_root}/config" \
  "${filebrowser_data_root}/database"

echo "Done. FileBrowser state is writable by ${service_owner}."

for arr_service in sonarr radarr jackett; do
  arr_config_path="/datafolder/homeserver/services/${arr_service}/data/config"

  if [[ ! -d "${arr_config_path}" ]]; then
    echo "Skipping ${arr_service}: configuration directory does not exist."
    continue
  fi

  arr_config_path="$(realpath -e -- "${arr_config_path}")"

  if [[ ! "${arr_config_path}" =~ ^/datafolder/[^/]+/services/(sonarr|radarr|jackett)/data/config$ ]]; then
    echo "Refusing to modify an unexpected ${arr_service} config path: ${arr_config_path}" >&2
    exit 1
  fi

  echo "Updating ${arr_service} configuration ownership to ${service_owner}..."
  chown -R --no-dereference "${service_owner}" "${arr_config_path}"
done

echo "Done. Existing Sonarr, Radarr, and Jackett state is writable by ${service_owner}."

seerr_config_path="/datafolder/homeserver/services/overseerr/data/config"

if [[ -d "${seerr_config_path}" ]]; then
  seerr_config_path="$(realpath -e -- "${seerr_config_path}")"

  if [[ ! "${seerr_config_path}" =~ ^/datafolder/[^/]+/services/overseerr/data/config$ ]]; then
    echo "Refusing to modify an unexpected Seerr migration path: ${seerr_config_path}" >&2
    exit 1
  fi

  echo "Updating Seerr migration configuration ownership to 1000:1000..."
  chown -R --no-dereference 1000:1000 "${seerr_config_path}"
  echo "Done. The migrated Seerr state is writable by 1000:1000."
else
  echo "Skipping Seerr: legacy Overseerr configuration directory does not exist."
fi

if [[ -e /etc/resolv.conf ]]; then
  echo "Restricting host resolver configuration permissions..."
  chown root:root /etc/resolv.conf
  chmod 0644 /etc/resolv.conf
  echo "Done. /etc/resolv.conf is owned by root and is not writable by other users."
fi
