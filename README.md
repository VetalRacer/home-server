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
- [docker.io/nginx](https://hub.docker.com/_/nginx) - the [docker.io/nginx](https://hub.docker.com/_/nginx) Gitlab server image.
- [ghcr.io/crazy-max/samba](https://hub.docker.com/r/crazymax/samba) - the [ghcr.io/crazy-max/samba](https://hub.docker.com/r/crazymax/samba) Gitlab server image.


## Support

- Github issues: [vetalracer/home-server/issues](https://github.com/vetalracer/home-server/issues)
