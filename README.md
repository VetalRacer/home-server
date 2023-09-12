# Home server setup using Ansible and Docker

This [Ansible](https://www.ansible.com/) playbook can help you set up a services:

- on your own Debian/CentOS/RedHat server
- with all services (Nginx, Gitlab, etc.) being put in [Docker](https://www.docker.com/) containers
- powered by the [vetalracer/home-server](https://github.com/vetalracer/home-server) Docker image


## Installation

To configure and install services on your home server, follow the [README in the docs/ directory](docs/README.md).


## Docker images used by this playbook

This playbook sets up your server using the following Docker images:

- [gitlab/gitlab-ee](https://hub.docker.com/r/gitlab/gitlab-ee) - the [gitlab/gitlab-ce](https://hub.docker.com/r/gitlab/gitlab-ee) Gitlab server image.
- [jwilder/nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy) - the [jwilder/nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy) Nginx image.
- [vetalracer/docker-samba](https://hub.docker.com/r/vetalracer/docker-samba) - the fork [ghcr.io/crazy-max/samba](https://hub.docker.com/r/crazymax/samba) Samba image.
- [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission) - the [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission) Transmission image.
- [linuxserver/plex](https://hub.docker.com/r/linuxserver/plex) - the [linuxserver/plex](https://hub.docker.com/r/linuxserver/plex) Plex image.
- [ghcr.io/benphelps/homepage](https://ghcr.io/benphelps/homepage) - the [benphelps/homepage](https://github.com/benphelps/homepage) Homepage image.
- [filebrowser/filebrowser](https://hub.docker.com/r/filebrowser/filebrowser) - the [filebrowser/filebrowser](https://hub.docker.com/r/filebrowser/filebrowser) FileBrowser image.
- [pihole/pihole](https://hub.docker.com/r/pihole/pihole) - the [pihole/pihole](https://hub.docker.com/r/pihole/pihole) Pi-hole image.
- [shawly/ps3netsrv](https://hub.docker.com/r/shawly/ps3netsrv) - the [shawly/ps3netsrv](https://hub.docker.com/r/shawly/ps3netsrv) ps3netsrv image.
- [henrywhitaker3/speedtest-tracker](https://hub.docker.com/r/henrywhitaker3/speedtest-tracker) - the [henrywhitaker3/speedtest-tracker](https://hub.docker.com/r/henrywhitaker3/speedtest-tracker) Speedtest-Tracker image.
- [linuxserver/overseerr](https://hub.docker.com/r/linuxserver/overseerr) - the [linuxserver/overseerr](https://hub.docker.com/r/linuxserver/overseerr) Overseerr image.
- [linuxserver/sonarr](https://hub.docker.com/r/linuxserver/sonarr) - the [linuxserver/sonarr](https://hub.docker.com/r/linuxserver/sonarr) Sonarr image.
- [linuxserver/radarr](https://hub.docker.com/r/linuxserver/radarr) - the [linuxserver/radarr](https://hub.docker.com/r/linuxserver/radarr) Radarr image.
- [linuxserver/jackett](https://hub.docker.com/r/linuxserver/jackett) - the [linuxserver/jackett](https://hub.docker.com/r/linuxserver/jackett) Jackett image.
- [linuxserver/tvheadend](https://hub.docker.com/r/linuxserver/tvheadend) - the [linuxserver/tvheadend](https://hub.docker.com/r/linuxserver/tvheadend) TVHeadend image.
- [alexta69/metube](https://hub.docker.com/r/alexta69/metube) - the [alexta69/metube](https://hub.docker.com/r/alexta69/metube) MeTube image.
- [sonatype/nexus3](https://hub.docker.com/r/sonatype/nexus3) - the [sonatype/nexus3](https://hub.docker.com/r/sonatype/nexus3) Nexus image.
- [prom/prometheus](https://hub.docker.com/r/prom/prometheus) - the [prom/prometheus](https://hub.docker.com/r/prom/prometheus) Prometheus image.
- [grafana/grafana](https://hub.docker.com/r/grafana/grafana) - the [grafana/grafana](https://hub.docker.com/r/grafana/grafana) Grafana image.
- [postgres](https://hub.docker.com/_/postgres) - the [postgres](https://hub.docker.com/_/postgres) Postgres image.
- [dpage/pgadmin4](https://hub.docker.com/r/dpage/pgadmin4) - the [dpage/pgadmin4](https://hub.docker.com/r/dpage/pgadmin4) pgAdmin image.
- [ccrisan/motioneye](https://hub.docker.com/r/ccrisan/motioneye) - the [ccrisan/motioneye](https://hub.docker.com/r/ccrisan/motioneye) MotionEye image.
- [ghcr.io/yourok/torrserver](https://ghcr.io/yourok/torrserver) - the [yourok/torrserver](https://ghcr.io/yourok/torrserver) Torrserver image.

## Support

- Github issues: [vetalracer/home-server/issues](https://github.com/vetalracer/home-server/issues)
