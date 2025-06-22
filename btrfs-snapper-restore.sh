#!/bin/bash
# Btrfs Snapper Repair Helper für Live-Systeme
# Erlaubt manuelle Auswahl und halbautomatisches Wiederherstellen eines Snapshots.

set -e

echo "====== Btrfs Snapper Repair Helper ======"
echo "Hinweis: Verwende dieses Skript nur aus einer Live-Umgebung!"
echo

# 1. Verfügbare Btrfs-Partitionen anzeigen
echo ">> Verfügbare Btrfs-Partitionen:"
lsblk -f | grep btrfs
echo

# 2. User wählt seine Partition
read -rp ">> Gib den Gerätenamen deiner Btrfs Root-Partition ein (z.B. /dev/nvme0n1p1): " DEVICE

# 3. Mountpunkt vorbereiten
mkdir -p /mnt/restore
echo ">> Btrfs Partition wird mit Subvolid=5 gemountet..."
mount -o subvolid=5 $DEVICE /mnt/restore

# 4. Subvolumes auflisten
echo
echo ">> Gefundene Subvolumes:"
btrfs subvolume list /mnt/restore | tee /tmp/btrfs_subvol_list.txt
echo

# 5. Prüfen ob .snapshots existiert
if ! grep -q ".snapshots" /tmp/btrfs_subvol_list.txt; then
    echo "WARNUNG: Kein '.snapshots' Subvolume gefunden. Abbruch."
    umount /mnt/restore
    exit 1
fi

# 6. User wählt Snapshot
echo
echo ">> Verfügbare Snapshots:"
SNAPSHOT_PATHS=$(btrfs subvolume list /mnt/restore | grep ".snapshots/" | awk '{print $9}')
echo "$SNAPSHOT_PATHS"

read -rp ">> Gib die vollständige Snapshot-Pfad-ID ein (z.B. .snapshots/25/snapshot): " SNAP_PATH

if [ ! -d "/mnt/restore/$SNAP_PATH" ]; then
    echo "Fehler: Snapshot $SNAP_PATH existiert nicht!"
    umount /mnt/restore
    exit 1
fi

# 7. Aktuelles @ sichern
if [ -d "/mnt/restore/@" ]; then
    echo ">> Sichern des aktuellen @ Subvolumes nach @_broken..."
    mv /mnt/restore/@ /mnt/restore/@_broken
else
    echo "WARNUNG: Subvolume @ nicht gefunden, wird übersprungen."
fi

# 8. Snapshot nach @ wiederherstellen
echo ">> Snapshot $SNAP_PATH wird als neues @ Subvolume erstellt..."
btrfs subvolume snapshot "/mnt/restore/$SNAP_PATH" "/mnt/restore/@"

# 9. Fertig
echo ">> Wiederherstellung abgeschlossen."
echo ">> Bitte überprüfe /etc/fstab und Snapper Konfiguration nach dem Neustart manuell!"
echo ">> Danach: Booten und Snapper testen."

# 10. Aufräumen
umount /mnt/restore
echo ">> Partition ausgehängt."

echo "====== Fertig ======"
