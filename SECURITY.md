# Security, Privacy and Provenance

## Do not publish captures blindly

USB Clone profiles can contain device serial numbers, descriptors, filesystem/partition metadata, udev data and complete disk images. Treat captured profiles as private by default.

This repository intentionally excludes the real profiles captured during development.

## Never commit

- disk images or private removable-media contents;
- credentials, keys or tokens;
- real USB serial numbers unless explicitly intended for a public synthetic fixture;
- raw device/udev dumps from private hardware;
- fixed private workstation paths/usernames;
- proprietary third-party binaries or licensed application data.

## Synthetic examples

Examples should use clearly synthetic VID/PID/serial values and small generated backing images. Do not create a fixture by lightly editing a private real-device capture.

## Upstream Linux source

`dummy_hcd` is part of the Linux kernel. AAG does not claim authorship of `dummy_hcd.c`. Prefer extracting the matching source from the user's distribution Linux source package at build time. If upstream source is ever redistributed, preserve its SPDX identifier, copyright and license obligations exactly.

## Privilege boundary

Creating ConfigFS gadgets, loading kernel modules and installing modules/configuration require root privileges. Public scripts should minimize the privileged surface and validate device/profile names and paths before writing to ConfigFS or module trees.

## Destructive operations

Full-device capture and unmount workflows operate on block devices. Scripts must verify that a selected object is a whole USB disk and should require explicit operator selection. Never infer a target disk from a fragile `/dev/sdX` assumption.

## Reporting

Do not include private device captures in public bug reports. Reduce a problem to synthetic metadata/logs before sharing.