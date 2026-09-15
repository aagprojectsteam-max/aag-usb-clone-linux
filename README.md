# AAG USB Clone for Linux

A Linux toolkit and engineering reference for creating virtual USB mass-storage devices with ConfigFS and `dummy_hcd`.

> **Publication status:** source-reconciliation preview. This repository is being reconstructed from the accepted live installation, retained toolkit sources, and historical handoff evidence. Private device identifiers, raw disk images, machine-specific paths, and proprietary data are intentionally excluded.

## What this project does

AAG USB Clone captures the identity and/or content of a USB mass-storage device into a local profile and exposes that profile as a virtual USB gadget. The Linux implementation uses the kernel USB gadget stack, ConfigFS, `libcomposite`, `usb_f_mass_storage`, and `dummy_hcd`.

The project also contains the engineering needed to keep `dummy_hcd` usable across kernel updates and documents optional integration with suspend and Windows/WinBoat guest workflows.

## Important boundaries

- Raw `.img`, `.iso`, `.vhd*`, `.qcow2`, and similar disk images are **not published**.
- Real USB serial numbers, captured descriptors, udev dumps, and private workstation paths are **not published**.
- `dummy_hcd.c` is Linux kernel source, not AAG-authored code. The public project should obtain/build the matching source from the installed Linux source package rather than claim ownership of a copied kernel source file.
- Windows-native USB work and the Linux ConfigFS implementation are historically related investigations but are **not the same implementation**.
- Otzar/WinBoat-specific activation and modem/suspend wiring are optional integrations, not requirements of the generic USB Clone toolkit.

## Development and validation environment

The principal development workstation is one physical dual-boot computer running Ubuntu 26.04 LTS and Windows 11 Pro. Documentation distinguishes physical Ubuntu-host validation, physical Windows-host validation, Windows guest/WinBoat validation, and CI. Dual boot by itself is not evidence of cross-platform acceptance.

The 2026-09-15 publication capture verified the accepted Ubuntu installation on kernel `7.0.0-31-generic`: the canonical `dummy_hcd` source used by the installed self-heal path was present, the installed USB Clone command and services were captured, and no disk image was included in the publication review archive.

## Documentation

- [Complete handoff](docs/HANDOFF.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Installation and kernel compatibility](docs/INSTALLATION.md)
- [Testing and evidence](docs/TESTING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Privacy, provenance and publication rules](SECURITY.md)
- [History](docs/HISTORY.md)

## Current publication phase

The live source capture contained 35 review files: toolkit source, historical build material, four installed implementation files, three systemd integration files, three retained documentation sources, and profile evidence. The public repository is intentionally narrower: only reusable AAG-authored source and sanitized documentation/examples belong here.

See `docs/HANDOFF.md` for the full evidence boundary and remaining reconciliation work.