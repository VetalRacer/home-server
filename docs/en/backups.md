# GitLab backups

The GitLab role creates a daily backup at 04:12 in
`{{ backups_base_data_path }}/gitlab` (normally
`/datafolder/homeserver/backups/gitlab`). The directory is mode `0700`; each
archive is mode `0600` and owned by the `gitlab_backup_user` (default:
`backup`). A manual backup is available with:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=backup-gitlab --ask-vault-pass
```

Each archive contains the GitLab application backup, `/etc/gitlab` (including
`gitlab-secrets.json`), the managed GitLab environment file, and the GitLab
Shell SSH host keys. The role keeps 14 archives by default; change
`gitlab_backup_days_to_keep_local` to adjust it.

Archives are **not encrypted** by the role. The filesystem permissions protect
them only on this server. Copy them to separately mounted/off-host storage and
encrypt that copy when protection against disk or host loss is required.

To fetch archives over SSH, add public keys to
`gitlab_backup_user_authorized_keys`; that account can read these sensitive
archives.

## Yandex Disk replica

Define `gitlab_backup_yandex_token` as an Ansible Vault value to enable uploads
of completed archives to `app:/gitlab` on Yandex Disk. The role keeps remote
copies for 30 days by default. The OAuth token needs access only to the Yandex
Disk application folder. Advanced installations may override
`gitlab_backup_yandex_directory` or `gitlab_backup_yandex_days_to_keep`.

## Restoring a GitLab backup

Restoring changes GitLab data. Stop normal use and make a fresh backup first.
The archive must be restored with the exact GitLab image version that created
it; do not use this procedure as an upgrade path.

1. Copy the archive to `gitlab_backup_directory` on the server.
2. Set `gitlab_docker_image_tag` to the version recorded in the archive's
   `backup_information.yml` (for example, a backup reporting `15.5.1-ee`
   requires `15.5.1-ee.0`).
3. Render the service but do not change the GitLab image version.
4. Run:

```bash
ansible-playbook -i inventory/hosts setup.yml \
  --tags=restore-backup --ask-vault-pass \
  --extra-vars='gitlab_archive_name=ARCHIVE_NAME.tar.gz'
```

The role verifies the embedded version, restores configuration, secrets and SSH
host keys, restores the application data, and runs `gitlab:doctor:secrets`.
Verify sign-in, projects, CI variables and SSH clone access afterwards.
