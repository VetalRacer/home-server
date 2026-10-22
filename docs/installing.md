# Installing

After [configuring the playbook](configuring-playbook.md), you're ready to install.

Run the playbook: `make setup-all`. Make asks for the Ansible Vault password
before running Ansible. For unattended use with a protected vault-password
file, override the default argument, for example:

```bash
make setup-all ANSIBLE_VAULT_ARGS="--vault-password-file /secure/path/vault-password"
```

After installing, you can start services: `make start`.
Gitlab may take a minute or so to actually start.

## Initial RAID setup

Before install you should change `raid_installation_enabled` variable in host-vars and change variables in raid task

Original repository: `https://github.com/mrlesmithjr/ansible-mdadm`

## Initial Gitlab setup

After some time, you should be able to access your new GitLab instance at:
`http://gitlab.DOMAIN`. The default role is intentionally for a local network
and does not configure TLS. Put a dedicated TLS reverse proxy in front of it
before exposing GitLab outside the LAN.

SSH clone URLs use port `2222` by default, so the host's own SSH daemon can
remain on port `22`.

The GitLab role disables the image's bundled Prometheus stack by default: the
repository supplies a separate Prometheus service. This prevents duplicated
monitoring processes and reduces GitLab's resource use. Set
`gitlab_builtin_monitoring_enabled: true` only when the bundled stack is
specifically needed.
Going there, you'll be taken to a "set new password" page, which will let you assign a password for the default `root` user.

Feel free to create more users after that and even delete this `root` user.


## Post-install configuration

After you're convinced that Gitlab is running, you should finish-up your configuration (what you started doing during [configuring](configuring-playbook.md)).

In the future, if you are to restore a backup or otherwise rebuild the Gitlab server, you'd wish to also restore the SSH host keys for the Gitlab Shell server.

The backup archive includes those keys. Defining them in Ansible Vault is still
useful when rebuilding the server from configuration alone, so you should let
the playbook manage them as well.
Edit your `inventory/host_vars/gitlab.<your-domain>/vars.yml` file and uncomment and populate the `gitlab_shell_ssh_host_keys` variable.

The SSH host keys are in `/gitlab/gitlab/data/ssh` (`gitlab_data_ssh_dir_path`) on the server.
You can paste the content for each key in the corresponding place in `gitlab_shell_ssh_host_keys`.
We recommend encrypting the values using `ansible-vault encrypt_string`.
