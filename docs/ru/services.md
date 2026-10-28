# Сервисы

Все сервисы включаются отдельной переменной
`<service>_installation_enabled: true`. Образы и hostname задаются в host vars;
не храните реальные пароли, токены, IP-адреса и ключи в Git. Для секретов
используйте Ansible Vault. Если не сказано иное, веб-интерфейс доступен через
`nginx-proxy` только в локальной сети.

## Nginx-proxy

Nginx-proxy маршрутизирует HTTP-запросы к контейнерам общей Docker-сети. По
умолчанию он слушает порт `80` только на основном LAN-адресе сервера
(`nginx_proxy_listen_address`). HTTP не шифруется и не добавляет
аутентификацию: не публикуйте этот порт в Интернет без отдельного TLS-proxy и
контроля доступа. Размер загрузок регулирует `nginx_proxy_client_max_body_size`.

## GitLab

GitLab рассчитан на LAN. Для внешнего доступа необходимы TLS и дополнительная
защита на proxy. Порт SSH-клонирования настраивается через
`gitlab_ssh_host_port` и по умолчанию равен `2222`; системный SSH остаётся
независимым. Встроенный мониторинг GitLab выключен: используйте отдельный
Prometheus. Резервное копирование описано в [отдельной инструкции](backups.md).

## Samba

Samba по умолчанию слушает основной LAN-интерфейс и принимает клиентов из
напрямую подключённой подсети. Для нескольких сетей задайте
`samba_listen_address` и `samba_allowed_hosts`. Для каждого пользователя из
`samba_users` укажите непустой пароль в карте `samba_user_passwords` и храните
его в Vault. Доступ к папкам задаётся через `samba_shares` и списки
`read_users`/`write_users`; SMB1 и гостевой fallback отключены.

## Transmission

Веб-интерфейс защищён `transmission_username` и `transmission_password`.
Оба значения должны быть Vault-секретами. Контейнер по умолчанию работает как
`1000:100` — та же идентичность, что и Samba `admin:users`; меняйте UID и GID
одновременно, если файлы загрузок принадлежат другой учётной записи.

## Plex

Plex по умолчанию работает как `1000:100`; каталоги медиа и загрузок
монтируются только для чтения, запись разрешена лишь в конфигурацию. Используйте
одноразовый `plex_claim` только при первичной привязке сервера и храните его,
как и `plex_apikey` для Homepage, в Vault. Удалённый доступ Plex требует
опубликованного TCP-порта `32400`.

## Homepage

Homepage показывает ссылки и состояние контейнеров. Для статусов используется
локальный ограниченный Docker API proxy: не монтируйте Docker socket прямо в
Homepage и не публикуйте proxy наружу. Отключить интеграцию можно через
`homepage_docker_integration_enabled: false`.

Язык интерфейса задаётся для каждого хоста переменной `homepage_language`.
Значение по умолчанию — `"en"`; для русского интерфейса укажите
`homepage_language: "ru"`. Эта же настройка переводит описания плиток,
заголовки разделов, системные виджеты и группы закладок.

`homepage_full_width` по умолчанию включён: группы сервисов используют всю
доступную ширину окна. На узких экранах Homepage всё равно переносит группы,
чтобы карточки оставались читаемыми.

## File Browser

File Browser работает как `1000:100`. По умолчанию он видит всё дерево
sharefolder; если это избыточно, ограничьте `filebrowser_root_path`. Создайте
уникальный сильный пароль администратора. Встроенная аутентификация не имеет
защиты от перебора, поэтому используйте доверенную LAN, VPN или дополнительный
контроль доступа на proxy.

## Pi-hole

Pi-hole публикует DNS только на основном LAN-адресе; для нескольких интерфейсов
задайте `pihole_dns_listen_address`. Пароль администратора обязателен и должен
быть Vault-секретом. `pihole_dhcp_enabled` включайте только если Pi-hole —
единственный DHCP-сервер в сети: режим открывает UDP 67 и даёт контейнеру
`NET_ADMIN`. Не включайте его вместе с DHCP на роутере. Управление resolver
хоста выключено по умолчанию.

Локальные DNS A-записи задавайте декларативно через
`pihole_local_dns_records`. Роль создаёт отдельный Ansible-managed файл в
`/etc/dnsmasq.d` и перезапускает Pi-hole только при его изменении. Не создавайте
те же имена вручную в UI: Pi-hole v6 генерирует собственный `custom.list`.
Один элемент объединяет IP и несколько имён:

```yaml
pihole_local_dns_records:
  - address: "192.168.1.200"
    hostnames:
      - "homepage.loc"
      - "grafana.loc"
```

## ps3netsrv

ps3netsrv раздаёт игры PS3 по TCP `38008`, обычно только на LAN-адресе.
Контейнер работает как `1000:100`; библиотека монтируется read-only по
умолчанию. Роль создаёт каталоги `GAMES`, `PKG`, `PS2ISO`, `PS3ISO`, `PSPISO`
и `PSXISO`, не перемещая существующие файлы.

## Speedtest Tracker

Перед запуском создайте Vault-значения `speedtest_app_key` и
`speedtest_admin_password`. APP_KEY генерируется так:

```bash
echo "base64:$(openssl rand -base64 32)"
```

Проверка скорости запускается каждый час по умолчанию, результаты хранятся
365 дней. Для виджета Homepage создайте в UI токен API только с правом
`Read Results`, сохраните его как `speedtest_homepage_api_key` в Vault и
переразверните Homepage.

## Seerr, Sonarr, Radarr и Jackett

Seerr заменяет Overseerr и управляет запросами фильмов/сериалов для Plex,
Sonarr и Radarr. При миграции он использует существующий каталог конфигурации;
не запускайте старый Overseerr после первого старта Seerr.

Sonarr и Radarr работают как `1000:100` с `UMASK=002`; библиотеки находятся в
`/data/media/tv` и `/data/media/movies`, а загрузки Transmission — в
`/data/torrent/downloads`. Для download-клиента настройте Remote Path Mapping:
host `transmission`, remote `/downloads`, local `/data/torrent/downloads`.
Это позволяет импортировать через hardlink без копирования.

Jackett доступен только через proxy, а Sonarr/Radarr должны обращаться к нему
по `http://jackett:9117`. Установите Admin Password в его UI до включения
External Access. Самообновление приложения выключено; обновляйте только
закреплённый тег образа.

## MeTube

MeTube — веб-интерфейс yt-dlp. У него нет встроенной многопользовательской
аутентификации: не публикуйте сервис в Интернет. Пользовательские параметры
yt-dlp и каталоги загрузок отключены, так как это снижает риск запуска
нежелательных команд и записи вне управляемого каталога. По умолчанию: одна
одновременная задача и максимум 200 элементов плейлиста.

## Nexus

Nexus хранит внутренние и proxy-репозитории пакетов и образов. Данные находятся
в `/nexus-data` и принадлежат runtime-пользователю `200:200`. Пароль первого
администратора появляется в `admin.password` в каталоге данных: используйте
его один раз и немедленно смените. Политику anonymous access и аутентификацию
настраивайте внутри Nexus. Перед обновлением версии делайте
Nexus-consistent backup и изучайте путь миграции Sonatype.

## Prometheus и Grafana

Prometheus собирает метрики хоста и дополнительные job из
`prometheus_additional_scrape_jobs`. Grafana в той же Docker-сети использует
`http://prometheus:9090`. Публикация UI/API Prometheus через proxy выключена
по умолчанию, поскольку Prometheus не имеет встроенной аутентификации.

node exporter, Blackbox, SMART exporter и cAdvisor доступны только внутри
Docker-сети. cAdvisor и SMART exporter работают с `--privileged`, необходимым
для метрик контейнеров и дисков; считайте их доверенной инфраструктурой.

Grafana требует Vault-значения `grafana_password` и постоянный
`grafana_secret_key` длиной не менее 32 символов. Не меняйте secret key после
начала работы: он шифрует сохранённые секреты. Provisioned dashboards и
datasource доступны только для чтения; для правок сначала сделайте копию в UI.
Виджет Homepage обращается к Grafana по `grafana_service_hostname` через
внутренний Docker alias: запрос не покидает Docker-сеть и не конфликтует с
проверкой канонического Host header в Grafana. Для API используется внутренний
`grafana_service_port`, а не порт proxy `80`.

## PostgreSQL и pgAdmin

PostgreSQL доступен контейнерам как `postgres`; для LAN-клиентов TCP-порт
привязан только к `postgres_listen_address`, а не к nginx-proxy. Значения
`postgres_user`, `postgres_password` и `postgres_database` применяются только
при пустом каталоге БД. Дампы содержат все данные и роли: храните их на
отдельном защищённом носителе и проверяйте восстановление.

pgAdmin доступен только через proxy и соединяется с PostgreSQL по Docker-сети.
`pgadmin_password` — Vault-секрет, применяемый лишь при первом создании базы
pgAdmin; смена переменной не сбрасывает уже существующий пароль.

## MotionEye

Веб-интерфейс MotionEye идёт через proxy, поток — на LAN-порт `8081`.
Ограничьте этот порт доверенными клиентами. Роль сохраняет единоразовый архив
конфигурации перед миграцией образа, но не копирует записи камеры: сделайте
отдельную копию `config` и `media` перед крупным обновлением. Для USB-камер
отдельно проверьте mapping устройств и разрешения.

## TorrServer и TubeArchivist

TorrServer доступен через proxy, HTTP-аутентификация включена. Пароли admin и
guest должны отличаться и храниться в Vault. Peer/DHT-порт не публикуется:
исходящие пиры работают, входящие — нет, пока вы явно не добавите порт.

TubeArchivist, Redis и Elasticsearch общаются только в Docker-сети. Пароли
TubeArchivist и Elasticsearch — Vault-секреты; они инициализируют новый архив,
но не меняют существующие учётные данные. Elasticsearch требует
`vm.max_map_count=262144`; роль устанавливает это значение.

## Nextcloud

При управляемом PostgreSQL роль создаёт пользователя и БД Nextcloud только при
их отсутствии, не меняя существующие данные. Пароли администратора и БД
должны находиться в Vault. `nextcloud_service_hostname` — канонический URL:
роль синхронизирует его с `overwritehost` и trusted domain.

Фоновый `cron.php` запускается каждые пять минут. Ежедневная копия содержит
дамп PostgreSQL и `main`, `apps`, `config`, `data`; maintenance mode включается
только на время архивации. Настройте `nextcloud_backup_path` на отдельном
хранилище. Для HTTPS через reverse proxy задайте
`nextcloud_overwrite_protocol: "https"` и `nextcloud_overwrite_cli_url`.

## Immich

Immich разворачивает web server, machine-learning, Valkey и отдельный
PostgreSQL с VectorChord; общий PostgreSQL намеренно не используется. Только
web server доступен через proxy. Сервер и machine-learning всегда должны иметь
одинаковый тег образа; `immich_db_password` хранится в Vault.

Исходники, превью и видео находятся в `immich/upload`, БД — в
`immich/postgres`. Используйте локальное хранилище, не SMB/NFS. Модель Smart
Search выбирается в `Administration → Settings → Machine Learning Settings`.
Для русского поиска подходит `nllb-clip-base-siglip__v1`; после смены модели
запустите `Smart Search: All`. Модель требует около 4.7 ГиБ RAM.

Роль ежедневно останавливает только web-контейнер на короткое время, делает
дамп БД и архив `upload`. Архивы лежат в `immich_backup_path` 14 дней;
разместите путь на отдельном/off-host хранилище. Ручной запуск:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=backup-immich --ask-vault-pass
```

## SearXNG

SearXNG доступен через proxy, Valkey остаётся внутренним и используется для
ограничения запросов. Создайте уникальный `searxng_secret_key` в Vault:
`openssl rand -hex 32`. Не редактируйте файлы конфигурации на сервере: Ansible
управляет `settings.yml` и `limiter.toml`.

## Planka

При управляемом PostgreSQL роль создаёт пользователя и БД Planka только если
их ещё нет. Пароль БД, `planka_secret_key` и пароль администратора храните в
Vault. Для миграции существующей v1 сначала отрендерьте v2 без запуска
(`--tags=setup-planka`), затем выполните на сервере от root
`scripts/migrate_planka_v1_to_v2.sh --execute`, после чего запустите
`--tags=start-planka`. Скрипт сохраняет dump и файлы v1 в
`planka/migration-backups/` и оставляет сервис остановленным.

## Quake 3 Server

Quake 3 использует UDP `27960`, не nginx-proxy. Для доступа из Интернета
оставьте `q3server_listen_address: 0.0.0.0` и пробросьте на роутере только UDP
`27960` на LAN-адрес сервера. Не пробрасывайте TCP. RCON и private-slot
пароли обязательны и должны быть Vault-секретами.

## Обновление образов

Теги образов закреплены ради воспроизводимых развёртываний. Обновляйте их
преднамеренно: сначала на `TARGET=test`, прочитав release notes и убедившись в
совместимости данных, затем на production.
