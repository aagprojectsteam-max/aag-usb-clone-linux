#!/usr/bin/env bash
set -Eeuo pipefail
[[ "${EUID:-$(id -u)}" -ne 0 ]] || { echo 'Run as a normal user; sudo is requested internally.' >&2; exit 1; }
HERE="$(cd -- "$(dirname -- "$0")" && pwd)"
COUNT="${1:-8}"
[[ "$COUNT" =~ ^[1-9][0-9]*$ ]] || { echo 'Controller count must be positive.' >&2; exit 2; }
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential "linux-headers-$(uname -r)" linux-source usbutils udev util-linux dosfstools exfatprogs rsync zstd gnupg mokutil openssl kmod libelf-dev bc flex bison xz-utils
sudo install -m 0755 "$HERE/bin/usbclone" /usr/local/sbin/usbclone
sudo install -m 0755 "$HERE/scripts/ensure-dummy-hcd" /usr/local/sbin/aag-usbclone-ensure-dummy-hcd
sudo env USBCLONE_DUMMY_COUNT="$COUNT" /usr/local/sbin/aag-usbclone-ensure-dummy-hcd
sudo tee /etc/modules-load.d/usbclone.conf >/dev/null <<'EOF'
dummy_hcd
libcomposite
usb_f_mass_storage
EOF
sudo modprobe libcomposite
sudo modprobe usb_f_mass_storage 2>/dev/null || true
mkdir -p "$HOME/USB-CLONES/profiles"
chmod 700 "$HOME/USB-CLONES" "$HOME/USB-CLONES/profiles"
/usr/local/sbin/usbclone doctor
cat <<'EOF'

AAG USB Clone public preview installed.
This preview intentionally does not expose capture/start of real identities yet.
Read docs/HANDOFF.md and docs/INSTALLATION.md before extending it.
EOF
