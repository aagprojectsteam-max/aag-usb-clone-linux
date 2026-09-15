#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL="$ROOT/bin/usbclone"
bash -n "$TOOL"
"$TOOL" --version | grep -q '2.0-public-rc1'
"$TOOL" help | grep -q 'capture-empty'
"$TOOL" help | grep -q 'start NAME'
"$TOOL" help | grep -q 'export NAME'
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/profiles/example"
cp "$ROOT/examples/profiles/example/profile.env" "$TMP/profiles/example/profile.env"
truncate -s 1M "$TMP/profiles/example/disk.img"
USB_CLONE_HOME="$TMP" "$TOOL" show example | grep -q 'example'
USB_CLONE_HOME="$TMP" "$TOOL" repo | grep -Fxq "$TMP"
echo 'PUBLIC_TOOL_SYNTHETIC_TEST=PASS'
