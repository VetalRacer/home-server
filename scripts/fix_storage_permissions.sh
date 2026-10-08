#!/usr/bin/env bash
# One-time migration of permissions after changing the Samba group and the
# FileBrowser runtime identity.
# Usage: sudo ./fix_storage_permissions.sh [share_root] [group] [filebrowser_data_root] [uid:gid]

set -euo pipefail

share_root="${1:-/datafolder/sharefolder}"
share_group="${2:-users}"
filebrowser_data_root="${3:-/datafolder/homeserver/services/filebrowser/data}"
filebrowser_owner="${4:-1000:100}"

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

if [[ ! "${filebrowser_owner}" =~ ^[1-9][0-9]*:[1-9][0-9]*$ ]]; then
  echo "FileBrowser owner must have the form UID:GID: ${filebrowser_owner}" >&2
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

echo "Updating FileBrowser configuration and database ownership to ${filebrowser_owner}..."
chown -R --no-dereference "${filebrowser_owner}" \
  "${filebrowser_data_root}/config" \
  "${filebrowser_data_root}/database"

echo "Done. FileBrowser state is writable by ${filebrowser_owner}."
