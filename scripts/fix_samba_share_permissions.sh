#!/usr/bin/env bash
# Grant a Unix group access to an existing Samba share tree.
# Usage: sudo ./fix_samba_share_permissions.sh [share_root] [group]

set -euo pipefail

share_root="${1:-/datafolder/sharefolder}"
share_group="${2:-users}"

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

echo "Updating group access under ${share_root} for group ${share_group}..."

# Do not follow symlinks. Owners and other-user permissions are preserved.
find -P "${share_root}" -exec chgrp "${share_group}" {} +
find -P "${share_root}" -type d -exec chmod g+rwx,g+s {} +
find -P "${share_root}" -type f -exec chmod g+rw {} +

echo "Done. Directories inherit group ${share_group}; existing owners were preserved."
