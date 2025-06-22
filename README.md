# btrfs-snapper-restore-helper
Skript zum Wiederherstellen von Btrfs Snapper Snapshots aus einer Live-Linux-Session

## Features

- Auflisten aller Btrfs Partitionen
- Auflisten und Auswahl vorhandener Snapper-Snapshots
- Backup des aktuellen Root-Subvolumes (`@`) nach `@_broken`
- Snapshot-Wiederherstellung als neues `@` Subvolume
- Schritt-für-Schritt Benutzerführung

## Anforderungen

- Linux Live-System (z. B. Arch/CachyOS ISO)
- Btrfs Root-Partition
- Snapper verwendet
- `btrfs-progs` installiert

## Nutzung

```bash
git clone https://github.com/dein-name/btrfs-snapper-restore-helper.git
cd btrfs-snapper-restore-helper
chmod +x btrfs-snapper-restore.sh
sudo ./btrfs-snapper-restore.sh
