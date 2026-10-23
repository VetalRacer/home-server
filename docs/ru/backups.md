# Резервные копии

## GitLab

Роль GitLab создаёт ежедневный архив в
`{{ backups_base_data_path }}/gitlab` (обычно
`/datafolder/homeserver/backups/gitlab`). Каталог имеет права `0700`, архивы —
`0600`; по умолчанию хранится 14 копий. Ручной запуск:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=backup-gitlab --ask-vault-pass
```

Архив содержит данные GitLab, `/etc/gitlab`, `gitlab-secrets.json`, env-файл и
SSH host keys GitLab Shell. Роль не шифрует архивы: копируйте их в отдельное
хранилище и шифруйте перед отправкой вне сервера.

При наличии Vault-переменной `gitlab_backup_yandex_token` готовый архив
выгружается в `app:/gitlab` на Яндекс Диске. Токену нужен доступ только к
папке приложения.

Для восстановления используйте образ **той же версии**, что создала архив:

```bash
ansible-playbook -i inventory/hosts setup.yml \
  --tags=restore-backup --ask-vault-pass \
  --extra-vars='gitlab_archive_name=ARCHIVE_NAME.tar.gz'
```

До восстановления остановите обычную работу GitLab и создайте свежую копию.
После него проверьте вход, проекты, CI-переменные и SSH-клонирование.

## PostgreSQL, Nextcloud и Immich

PostgreSQL создаёт ежедневные дампы по `postgres_backup_path`; Nextcloud и
Immich создают согласованные архивы с БД и данными. Их команды ручного запуска:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=backup --ask-vault-pass
ansible-playbook -i inventory/hosts setup.yml --tags=backup-nextcloud --ask-vault-pass
ansible-playbook -i inventory/hosts setup.yml --tags=backup-immich --ask-vault-pass
```

Задайте пути резервных копий на отдельно смонтированном или внешнем носителе.
Копия на том же диске не защищает от потери сервера. Регулярно проверяйте
восстановление на отдельной машине.
