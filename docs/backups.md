# Backups

Backups are created daily and automatically. After creating, they're gpg-encrypted (password specified by `gitlab_backup_encryption_password`) and then relocated to `gitlab_backup_directory` (default: `/homeserver/backup/`).

14 days worth of backups are kept locally by default (controllable by `gitlab_backup_days_to_keep_locally`).

Granting SSH access to this backup user is possible by defining a list of public keys in the `gitlab_backup_user_authorized_keys` variable.

Creating a backup manually is also possible: `make backup`.


## Remote backups

You can store backups remotely by:

- having them uploaded to [Yandex.Drive](https://disk.yandex.ru/) - see the `gitlab_backup_yandex_` variables

Backups uploaded remotely get purged by us.
You're advised to set up the appropriate lifecycle rules.
30 days worth of backups are kept Yandex.Drive by default (controllable by `gitlab_backup_yandex_days_to_keep`).


## Note on setting up Yandex.Drive backups

- We login on Yandex under the account, on the disk that we will backup, go to https://oauth.yandex.ru and click "Register a new application".
- Fill in the name of the application (for example, “backup”) and issue the necessary rights in the “Yandex.Disk REST API” section, namely: “Access to information about the Disk” and “Access to the application folder on the Disk”.
Below on the same page, under the "Callback URL" field, click "substitute URL for development" and click "Save".
- After saving the application settings, we will be redirected to the application data page.
- We get a token (if you want, you can read more about this in the Yandex manual), for this we copy the ID, substitute it at the end of the URL https://oauth.yandex.ru/authorize?response_type=token&client_id=, go to the resulting address and confirm granting permissions to the application.
- The page will display a token that is issued for at least 1 year, so if the backup script suddenly stops working, we can get a new token and substitute it into the script. You can test the capabilities of working with Yandex.Disk using the received token at [a special test site](https://tech.yandex.ru/disk/poligon/).

## Note on fetching backups via SSH

To get SSH access to the server with the `backup` user, so you can pull the backups from `/home/backup/backups`, you should put your public SSH key(s) in `gitlab_backup_user_authorized_keys`.


## Restoring a gitlab backup

- Note the version of Gitlab that was used for making the backup. For the example file name (`2022_12_05_15.5.1-ee_gitlab_backup.tar.gz`), it's `15.5.1`.

- Configure your inventory file (`inventory/host_vars/gitlab.DOMAIN/vars.yml`) with a custom variable: `gitlab_docker_image_tag: VERSION_HERE`. We need this to ensure that we'll install the same Gitlab version as the one used to make the backup.

- Rebuild the server using the Ansible playbook. See [Installing](installing.md). You may start services if you wish.

- Make sure the `.tar.gz` backup file is available in the `/homeserver/backup/gitlab/` directory (e.g. `/homeserver/backup/gitlab/2022_12_05_15.5.1-ee_gitlab_backup.tar.gz`)

- Ask the playbook to restore the backup:

```bash
ansible-playbook -i inventory/hosts setup.yml \
--tags=restore-backup \
--extra-vars='gitlab_archive_name=2022_12_04_15.5.1-ee_gitlab_backup.tar.gz'
```

- You may now wish to remove your custom version definitions from your `inventory/host_vars/gitlab.DOMAIN/vars.yml` file and re-run the playbook, so you would get upgraded to the latest version. See [Upgrading](upgrading.md).

- The restore operation enables the "Write to authorized_keys file" setting (Admin Area > Settings > Network > Performance Optimization). Consider disabling it, as it doesn't work well with containers.
