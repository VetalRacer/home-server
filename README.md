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


## Support

- Github issues: [vetalracer/home-server/issues](https://github.com/vetalracer/home-server/issues)
