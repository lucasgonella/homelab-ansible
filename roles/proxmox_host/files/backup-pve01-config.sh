#!/bin/bash

set -euo pipefail
umask 077

DEST="/mnt/pve/backup-desktop/host-config"
INFO="/root/pve01-backup-info"
DATE="$(date +%F_%H-%M)"
BACKUP="$DEST/pve01-config-$DATE.tar.gz"

# Garante que o storage de backup está acessível
if ! mountpoint -q /mnt/pve/backup-desktop; then
    logger -t pve01-config-backup "ERRO: backup-desktop não está montado"
    exit 1
fi

mkdir -p "$DEST"
mkdir -p "$INFO"

# Inventário atual do host
pveversion -v > "$INFO/pveversion.txt"
pvesm status > "$INFO/storage-status.txt"
pct list > "$INFO/lxc-list.txt"
qm list > "$INFO/vm-list.txt"
lsblk -f > "$INFO/lsblk.txt"
ip -br addr > "$INFO/ip-addresses.txt"
ip route > "$INFO/routes.txt"

dpkg-query -W -f='${binary:Package}\t${Version}\n' \
    > "$INFO/packages.txt"

# Banco do pmxcfs
cp -a /var/lib/pve-cluster/config.db \
    "$INFO/pve-cluster-config.db"

# Backup
tar \
    --numeric-owner \
    -czf "$BACKUP" \
    /etc/pve \
    /etc/network/interfaces \
    /etc/hosts \
    /etc/hostname \
    /etc/resolv.conf \
    /etc/zabbix \
    /etc/apt \
    /root/homelab-ca \
    "$INFO"

# Mantém somente os 7 backups mais recentes do host
find "$DEST" \
    -maxdepth 1 \
    -type f \
    -name 'pve01-config-*.tar.gz' \
    -printf '%T@ %p\n' \
    | sort -nr \
    | tail -n +8 \
    | cut -d' ' -f2- \
    | xargs -r rm -f

logger -t pve01-config-backup \
    "Backup concluído: $BACKUP"
