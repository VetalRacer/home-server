# Prerequisites

- **CentOS** (7.0+) or **Debian** (9/Stretch+) server. This playbook manages
  Docker and the ports required by enabled services, so running unrelated
  services on it is not recommended.

- SSH may remain on its existing port. GitLab clone URLs use the separately
  configurable `gitlab_ssh_host_port` (default `2222`), so port `22` is not
  reserved by GitLab. The base role disables SSH password authentication by
  default; ensure Ansible key-based access works before applying it.

- [Python](https://www.python.org/) being installed on the server. Most distributions install Python by default, but some don't

- the [Ansible](http://ansible.com/) program being installed on your own computer. It's used to run this playbook and configures your server for you
