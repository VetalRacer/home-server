# 2022-11-11

## Ansible 2.8 compatibility

The playbook now supports the new Ansible 2.8.

A manual change is required to the `inventory/hosts` file, changing the group name from `gitlab-servers` to `home_server` (dash to underscore).

To avoid doing it manually, run this:
- Linux: `sed -i 's/gitlab-servers/home_server/g' inventory/hosts`
- Mac: `sed -i '' 's/gitlab-servers/home_server/g' inventory/hosts`
