#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL="$ROOT/bin/usbclone"
run_tool(){ bash "$TOOL" "$@"; }
bash -n "$TOOL"
run_tool --version | grep -q '2.0-public-rc2'
run_tool help | grep -q 'capture'
run_tool help | grep -q 'start NAME'
run_tool help | grep -q 'export NAME'
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/profiles/example"
sed -e 's/^ID_VENDOR=/VID=/' \
    -e 's/^ID_PRODUCT=/PID=/' \
    -e 's/^MANUFACTURER=/USB_MANUFACTURER=/' \
    -e 's/^PRODUCT=/USB_PRODUCT=/' \
    -e 's/^SERIAL=/USB_SERIAL=/' \
    "$ROOT/examples/profile.env.example" > "$TMP/profiles/example/profile.env"
truncate -s 1M "$TMP/profiles/example/disk.img"
USB_CLONE_HOME="$TMP" bash "$TOOL" show example | grep -q 'USB_SERIAL=EXAMPLE0001'
USB_CLONE_HOME="$TMP" bash "$TOOL" repo | grep -Fxq "$TMP"
ARCHIVE="$TMP/example-export.tar.gz"
USB_CLONE_HOME="$TMP" bash "$TOOL" export example "$ARCHIVE" | grep -q 'exported:'
test -s "$ARCHIVE"
rm -rf "$TMP/profiles/example"
USB_CLONE_HOME="$TMP" bash "$TOOL" import "$ARCHIVE" example | grep -q 'imported: example'
grep -q 'USB_SERIAL=EXAMPLE0001' "$TMP/profiles/example/profile.env"
test -s "$TMP/profiles/example/disk.img"
echo 'PUBLIC_TOOL_SYNTHETIC_TEST=PASS'
