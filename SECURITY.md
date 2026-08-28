# Repository security policy

This repository is intended to be safe for public viewing as a HomeLab learning and portfolio project.

## Public scope

The repository may intentionally document RFC1918 private IP addresses, internal hostnames, Ansible roles, playbooks, service names and architecture. These values describe the logical lab topology and do not expose Pi-hole query history.

## Data excluded from Git

Runtime data and confidential material must stay outside the repository. This includes credentials, local secret files, private cryptographic material, Pi-hole query/history data, Zabbix database exports, Proxmox backup archives, application databases and environment files containing confidential values.

Only `inventory/group_vars/all/vault.example.yml` is tracked. The real local `inventory/group_vars/all/vault.yml` is ignored by Git.

## Before pushing

Always review staged content before pushing:

```bash
git status
git diff --cached
```

The `.gitignore` contains defensive patterns for common local secret and runtime-data file types, but it is not a substitute for reviewing changes.

## Pi-hole privacy

This repository does not store Pi-hole browsing/query history. Pi-hole query data remains runtime data on the Pi-hole host and is explicitly outside the scope of this Git repository.

## Accidental exposure

If confidential material is ever committed, treat the affected value as exposed, replace it, remove it from the working tree, and review Git history before making the repository public again.
