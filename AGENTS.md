# Repository guide for agents

## Purpose and architecture

This repository provisions a single `home_server` host with Ansible.  It installs
Docker, then manages each self-hosted application as a generated systemd unit
which runs a Docker container.  The root playbook is `setup.yml`; it applies
roles in dependency order.  `nginx-proxy` creates the shared Docker network,
and most application roles require that network.

Key locations:

- `setup.yml` — playbook and the authoritative list/order of enabled roles.
- `roles/<service>/defaults/main.yml` — overridable defaults, paths, image
  templates, and service lists.
- `roles/<service>/tasks/main.yml` — role entry point and public Ansible tags.
- `roles/<service>/tasks/setup_main.yml` — common directory/network checks.
- `roles/<service>/tasks/setup_<service>.yml` — directory/template installation.
- `roles/<service>/tasks/start.yml` — daemon reload and service restart.
- `roles/<service>/templates/` — systemd unit files and application
  configuration rendered on the managed host.
- `examples/host-vars.yml` and `examples/hosts` — public configuration
  examples.  Real inventory and host variables are deliberately local under
  `inventory/` and must not be committed.
- `docs/` — operator-facing installation, configuration, upgrade, and backup
  procedures.

## Local configuration and secrets

Operators copy `examples/hosts` to `inventory/hosts` and
`examples/host-vars.yml` to
`inventory/host_vars/home-server.<domain>/vars.yml`.  Keep real domains,
passwords, tokens, private keys, IP addresses, and backups out of Git.  When
adding a credential, use an empty/example value in the sample and document
that Ansible Vault (for example `ansible-vault encrypt_string`) is preferred.

The variable contract is:

- global data paths and Docker settings are in host vars;
- a service is opted in via `<service>_installation_enabled`;
- image tags are supplied via `<service>_docker_image_tag`;
- role defaults derive image names and paths from those values.

Preserve this separation: do not hard-code site-specific paths, hostnames,
credentials, or image tags in tasks or templates.

## Editing conventions

- Use valid Ansible/YAML with two-space nesting.  Keep the style already used
  by the role being changed (many task files begin with `---`; defaults are
  intentionally simple mappings).
- Prefer fully qualified Ansible module names in new code when practical, but
  do not churn unrelated existing tasks solely for style.
- Make changes idempotent: create directories, render templates, and manage
  unit state through Ansible modules.  A task should report changed only when
  managed state changes.
- Follow the established service-role shape: add the role to `setup.yml`, a
  defaults file, task entry point with `setup-all`, `setup-<service>`, and
  `start` tags, a systemd template, and an opt-in sample variable.  Add a
  service hostname and image-tag example when the service needs them.
- Systemd templates use `Environment="HOME={{ systemd_unit_home_path }}"` and
  `ExecStart=/usr/bin/docker run --rm --name <service> ...`; retain compatible
  `ExecStop`/restart behavior and ensure container/service names stay unique.
- If a container is reverse-proxied, attach it to
  `{{ nginx_docker_network }}` and keep its setup network check.  Account for
  its dependency on `nginx-proxy` being earlier in `setup.yml`.
- Update the appropriate `docs/` page and `examples/host-vars.yml` whenever a
  user-visible setting, service, port, setup step, or backup behavior changes.

## Commands and validation

Run commands from the repository root.  The Make targets operate on the local
`inventory/hosts` and therefore affect real infrastructure:

```bash
make help
ansible-playbook -i inventory/hosts setup.yml --syntax-check
ansible-playbook -i inventory/hosts setup.yml --list-tags
ansible-playbook -i inventory/hosts setup.yml --list-tasks
```

After a targeted role edit, prefer the least invasive check available:

```bash
ansible-playbook -i inventory/hosts setup.yml --tags=setup-<service> --check --diff
ansible-playbook -i inventory/hosts setup.yml --tags=setup-<service>,start --check --diff
```

Use `make setup-all`, `make start`, `make backup`, `make update`, and
`make setup-all-and-restart` only with explicit intent to change the managed
server.  There is no committed dependency manifest, test suite, or lint
configuration; do not claim a lint/test run unless the needed tooling and a
safe inventory were actually available.

## Operational safety

- Treat ordinary playbook runs as production changes: Docker images may be
  pulled, directories and systemd units replaced, and services restarted.
- Never run RAID initialization or `wipe_disks.yml` against a real host without
  explicit confirmation.  `raid_installation_enabled` and `mdadm_force_wipe`
  are especially destructive; inspect exact devices and mounts first.
- The Pi-hole preparation task stops/disables `systemd-resolved` and writes
  resolver configuration.  Verify DNS/network impact before applying it.
- Do not invoke `restore-backup`, rotate/delete backup data, or change
  GitLab/DB image versions during a maintenance task unless the request
  specifically covers backup/restore and compatibility.
- Be cautious with `latest` Docker tags: pin a compatible version when
  changing behavior or preparing a reproducible release.

## Repository-specific notes

- `roles/wud/` exists and has an example enable flag, but `wud` is currently
  absent from `setup.yml`; it is not deployed unless re-added deliberately.
- Preserve the role order in `setup.yml` unless a dependency analysis requires
  a change.  In particular, `server-base`, RAID, and `nginx-proxy` establish
  prerequisites for later roles.
- `gitlab` is special: it supplies `backup` and `restore-backup` tags and has
  runner/backup configuration.  Keep its validation and backup tasks intact
  when modifying the role.
