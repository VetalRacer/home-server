# Nginx-proxy

Nginx-proxy service proxies requests to internal services

You can find all configs in `roles/nginx-proxy/templates/nginx-proxy/conf.d/` folder

# Gitlab

Gitlab service help planning to production, brings teams together to shorten cycle times, reduce costs, strengthen security, and increase developer productivit

# Samba

Samba service provides file and print services for various Microsoft Windows clients and can integrate with a Microsoft Windows Server domain, either as a Domain Controller (DC) or as a domain member. As of version 4, it supports Active Directory and Microsoft Windows NT domains.

Samba is exposed only on the primary LAN interface and accepts clients from its
directly connected subnet by default. Override `samba_listen_address` and
`samba_allowed_hosts` for a multi-homed host. Before enabling the role, set
the `samba_user_passwords` YAML map with a non-empty password for every user
declared in `samba_users`; real values should be stored with Ansible Vault.
`samba_shares` defines the host path and `read_users` / `write_users` lists for
each share. The role uses the pinned upstream `ghcr.io/crazy-max/samba` image,
disables SMB1, disallows guest fallback, and keeps the rendered credentials
file readable only by root.

# Transmission

Transmission is a light-weight and cross-platform BitTorrent client.

The Web UI is reachable through the reverse proxy and is authenticated with
`transmission_username` and `transmission_password`. Store both values in
Ansible Vault; the role renders them only to a root-readable environment file
at `transmission_base_data_path/transmission.env`.

By default, Transmission uses UID `1000` and GID `100`, matching the default
Samba `admin:users` identity. Override `transmission_uid` and
`transmission_gid` together when your download storage is owned by another
account.

You can read more about configuration in the
[LinuxServer.io documentation](https://docs.linuxserver.io/images/docker-transmission/).

# Plex

Plex is an American streaming media service and a client–server media player platform, made by Plex, Inc. The Plex Media Server organizes video, audio, and photos from a user's collections and from online services, and streams it to the players. The official clients and unofficial third-party clients run on mobile devices, smart TVs, streaming boxes, and in web apps.

Plex runs as UID `1000` and GID `100` by default, matching the Samba
`admin:users` identity. Override `plex_uid` and `plex_gid` together when media
or configuration storage belongs to another account. Media and download mounts
are read-only; Plex can write only to its configuration directory.

Use a short-lived `plex_claim` only for the initial server claim and store it in
Ansible Vault. The role renders it to a root-readable environment file instead
of the systemd unit. The `plex_apikey` used by Homepage should also be stored in
Ansible Vault.

Plex Remote Access requires the published TCP port `32400`; the role keeps it
available on all host interfaces.

You can read more about configuration in the
[LinuxServer.io documentation](https://docs.linuxserver.io/images/docker-plex/).

# Homepage

A modern (fully static, fast), secure (fully proxied), highly customizable application dashboard with integrations for more than 25 services and translations for over 15 languages. Easily configured via YAML files (or discovery via docker labels)

You can read more about configured [here](https://gethomepage.dev/en/installation/)

Homepage displays container status through a local, allowlisted Docker API proxy.
The proxy has no host port and accepts only the Docker read endpoints needed for
status discovery. Do not mount `/var/run/docker.sock` into Homepage or expose
the proxy outside the Docker network. Set `homepage_docker_integration_enabled:
false` to disable container status discovery.

The Homepage image in the example configuration is `v2.4.0`.

# FileBrowser

File Browser provides a file managing interface within a specified directory and it can be used to upload, delete, preview, rename and edit your files. It allows the creation of multiple users and each user can have its own directory.

File Browser runs as UID `1000` and GID `100` by default, matching the Samba
`admin:users` identity. Override `filebrowser_uid` and `filebrowser_gid`
together when its configuration or root directory uses another account.
`filebrowser_root_path` defaults to the whole sharefolder tree; set it to a
subdirectory when the Web UI does not need access to every share.

The initial File Browser administrator account must have a unique, strong
password. Its built-in authentication has no brute-force protection, so expose
the service only through a trusted LAN, VPN, or additional reverse-proxy access
control.

You can read more about configuration in the
[File Browser documentation](https://filebrowser.org/).

# Pi-hole

Pi-hole is a Linux network-level advertisement and Internet tracker blocking application which acts as a DNS sinkhole and optionally a DHCP server, intended for use on a private network.

Pi-hole publishes DNS only on the server's primary LAN address by default. Set
`pihole_dns_listen_address` when the server has multiple network interfaces.
The admin password must be non-empty and should be encrypted with Ansible Vault;
the role writes it only to `pihole.env`, readable by root.

`pihole_dhcp_enabled` defaults to `false`. Enable it only when Pi-hole is your
LAN DHCP server; this publishes UDP port 67 and grants the container
`NET_ADMIN`. Do not enable it alongside DHCP on the router.

`pihole_dnsmasq_enabled` keeps `/etc/dnsmasq.d` mounted for existing custom
snippets and v5 migrations. Disable it for a new v6 installation that does not
use custom dnsmasq configuration.

The role no longer changes the host DNS resolver by default. The legacy
`pihole_manage_host_resolver: true` option stops `systemd-resolved` and renders
a static `/etc/resolv.conf`. Its fallback resolvers are `8.8.8.8` and
`1.1.1.1`; override `pihole_host_resolvers` when using different upstream DNS
servers. Existing hosts previously configured this way keep their current
resolver state until it is changed manually.

You can read more about configuration in the [official Pi-hole Docker documentation](https://docs.pi-hole.net/docker/).

# ps3netsrv

ps3netsrv serves PS3 games to webMAN-MOD or multiMAN over TCP port 38008.
The role binds that port only to the primary LAN address by default; override
ps3netsrv_listen_address on multi-homed hosts.

It runs as UID 1000 and GID 100, matching the default Samba admin:users
identity. Set ps3netsrv_uid and ps3netsrv_gid together when the games directory
belongs to another account. Games are mounted read-only by default; set
ps3netsrv_games_read_only: false only if writing to the library is required.

The role creates GAMES, PKG, PS2ISO, PS3ISO, PSPISO, and PSXISO below
ps3netsrv_game_path. Existing files are never moved or renamed.

The image is pinned to v2.0.1. Configure the same host address and port in the
PS3 client.

You can read more in the [image documentation](https://github.com/shawly/docker-ps3netsrv) and the [webMAN-MOD guide](https://github.com/aldostools/webMAN-MOD/wiki/~-PS3-NET-Server).

# Speedtest-Tracker

Speedtest Tracker periodically runs an Ookla speed test and stores the results in
its SQLite database. The role uses the maintained
[LinuxServer image](https://docs.linuxserver.io/images/docker-speedtest-tracker/)
and runs it as `speedtest_uid:speedtest_gid` (by default `1000:100`).

Before its first start, set `speedtest_app_key` and
`speedtest_admin_password` in host variables with Ansible Vault. Generate the
application key with `echo "base64:$(openssl rand -base64 32)"`; the default
administrator email is `admin@example.com`. The default schedule is hourly and
results are retained for 365 days; override `speedtest_schedule` and
`speedtest_prune_results_older_than` when needed.

The Homepage widget uses the version 2 Speedtest Tracker API. After the first
start, sign in as the administrator, open `/admin/api-tokens`, and create a
token with only the `Read Results` ability. Store it as
`speedtest_homepage_api_key` with Ansible Vault, then redeploy Homepage. Until
the token is configured, Homepage displays the Speedtest Tracker card without
the widget rather than making unauthenticated API requests.

See the [upstream documentation](https://docs.speedtest-tracker.dev/) for
application settings and usage.

# Seerr

Seerr is the supported successor to Overseerr. It manages media requests and
discovery for Plex, then sends approved movie and TV requests to Radarr and
Sonarr. It is available only through the reverse proxy at the configured
`seerr_service_hostname`; port 5055 is not published on the host.

For an Overseerr migration, Seerr deliberately reuses the existing host
configuration directory, but mounts it at `/app/config`, as required by the
official image. Before the first Seerr deployment, back up that directory and
run `scripts/fix_storage_permissions.sh` on the host so Seerr's `1000:1000`
runtime user can write it. The initial launch migrates the stored application
data; do not run the old Overseerr service afterwards.

During the setup wizard, connect Plex and use the Docker-network addresses
`http://sonarr:8989` and `http://radarr:7878` for the respective integrations.
Restrict request approval and administration permissions to trusted Plex users.
Update the pinned `seerr_docker_image_tag` only after reviewing Seerr's release
notes and migration guidance.

See the [official Seerr documentation](https://docs.seerr.dev/getting-started/)
and its [Overseerr migration guide](https://github.com/seerr-team/seerr/blob/develop/docs/migration-guide.mdx).

# Sonarr
This is a PVR for usenet and bittorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

Sonarr is available through the reverse proxy on port 8989 inside the Docker
network. It runs as the shared non-root `1000:100` identity with `UMASK=002`,
so newly created media files remain writable by the common group. Its library
is `/data/media/tv`; it also sees Transmission downloads at
`/data/torrent/downloads` through the common `/data` mount.

When adding Transmission as a download client, configure a Remote Path Mapping
with host `transmission`, remote path `/downloads`, and local path
`/data/torrent/downloads`. This preserves Transmission's existing path while
allowing Sonarr to hardlink completed downloads instead of copying them.

The image is pinned in host variables for predictable deployments. Review and
update its tag deliberately after checking the Sonarr release notes.

See the [LinuxServer image documentation](https://docs.linuxserver.io/images/docker-sonarr/)
and the [Sonarr Docker guide](https://wiki.servarr.com/en/sonarr/installation/docker)
for application configuration and storage-layout guidance.

# Radarr
Radarr manages movie downloads and imports. It is exposed through the reverse
proxy on port 7878 and runs as the shared non-root `1000:100` identity with
`UMASK=002`. Its movie library is `/data/media/movies`; completed Transmission
downloads are available at `/data/torrent/downloads` through the same mount.

When adding Transmission as a download client, configure a Remote Path Mapping
with host `transmission`, remote path `/downloads`, and local path
`/data/torrent/downloads`. This keeps completed torrents seedable while Radarr
imports the movie via a hardlink.

The image tag is pinned in host variables. Update it deliberately after
reviewing the release notes. See the
[LinuxServer image documentation](https://docs.linuxserver.io/images/docker-radarr/)
and the [Radarr Docker guide](https://wiki.servarr.com/en/radarr/installation/docker)
for application configuration.

# Jackett
Jackett translates Sonarr and Radarr indexer requests into tracker-specific
queries. Its web interface is available only through the reverse proxy at
`http://jackett.loc` (or the configured hostname); port 9117 is not published
directly on the host. Configure Sonarr and Radarr to use
`http://jackett:9117` on the shared Docker network.

Jackett runs as the shared non-root `1000:100` identity with `UMASK=002`. Its
indexer credentials, cookies, API key, and settings are stored in `/config`.
Set an Admin Password in the Jackett UI before enabling External Access. The
application self-update feature is disabled; update the pinned image tag
deliberately instead.

See the [LinuxServer image documentation](https://docs.linuxserver.io/images/docker-jackett/)
and the [Jackett troubleshooting guide](https://github.com/Jackett/Jackett/wiki/Troubleshooting)
for tracker and security configuration.

# MeTube
Web GUI for youtube-dl (using the yt-dlp fork) with playlist support. Allows you to download videos from YouTube and dozens of other sites (https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).

You can read more about configured [here](https://hub.docker.com/r/alexta69/metube)

# Nexus
Nexus3 Disaster Recovery (N3DR) is a tool that is capable of downloading all artifacts from a Nexus3 server and to migrate them to another one.

You can read more about configured [here](https://hub.docker.com/r/sonatype/nexus3)

# Prometheus
Prometheus is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.

You can read more about configured [here](https://hub.docker.com/r/prom/prometheus)

# Grafana
Grafana allows you to query, visualize, alert on and understand your metrics no matter where they are stored. Create, explore, and share dashboards with your team and foster a data-driven culture.

You can read more about configured [here](https://hub.docker.com/r/grafana/grafana) or [here](https://github.com/grafana/grafana)

# Postgres
Postgres is a free and open-source relational database management system (RDBMS) emphasizing extensibility and SQL compliance.

You can read more about configured [here](https://hub.docker.com/_/postgres)

# pgAdmin
pgAdmin 4 is a web based administration tool for the PostgreSQL database. 

You can read more about configured [here](https://www.pgadmin.org/support/list/)

# MotionEye
MotionEye is an online interface for the software motion, a video surveillance program with motion detection.

You can read more about configured [here](https://github.com/motioneye-project/motioneye/tree/dev)

# Torrserver
TorrServer, stream torrent to http.

You can read more about configured [here](https://github.com/YouROK/TorrServer)

# TubeArchivist
Your self hosted YouTube media server

You can read more about configured [here](https://github.com/tubearchivist/tubearchivist) or [here](https://www.tubearchivist.com/)

# Nextcloud
Your self hosted Nextcloud server. A safe home for all your data. Access & share your files, calendars, contacts, mail & more from any device, on your terms.

You can read more about configured [here](https://hub.docker.com/_/nextcloud) or [here](https://github.com/nextcloud/docker)

# Whoogle
Get Google search results, but without any ads, JavaScript, AMP links, cookies, or IP address tracking. Easily deployable in one click as a Docker app, and customizable with a single config file. Quick and simple to implement as a primary search engine replacement on both desktop and mobile.

You can read more about configured [here](https://hub.docker.com/r/benbusby/whoogle-search) or [here](https://github.com/benbusby/whoogle-search)

# Planka
Elegant open source project tracking.

You can read more about configured [here](https://hub.docker.com/r/linuxserver/planka) or [here](https://github.com/plankanban/planka)

# Quake3 Server
Quake3 Arena Server

You can read more about configured [here](https://hub.docker.com/r/vetalracer/q3server) or [here](https://hub.docker.com/r/vetalracer/q3server)
