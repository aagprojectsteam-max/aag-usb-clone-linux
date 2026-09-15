#!/usr/bin/env bash
set -Eeuo pipefail
[[ "${EUID:-$(id -u)}" -ne 0 ]] || { echo 'Run as a normal user.' >&2; exit 1; }
sudo /usr/local/sbin/usbclone stop-all 2>/dev/null || true
sudo rm -f /usr/local/sbin/usbclone /usr/local/sbin/aag-usbclone-ensure-dummy-hcd
sudo rm -f /etc/modprobe.d/usbclone-dummy-hcd.conf /etc/modules-load.d/usbclone.conf
K="$(uname -r)"; sudo rm -f "/lib/modules/$K/updates/usbclone/dummy_hcd.ko"; sudo depmod -a "$K"
echo 'AAG USB Clone tooling removed. ~/USB-CLONES was intentionally preserved.'
