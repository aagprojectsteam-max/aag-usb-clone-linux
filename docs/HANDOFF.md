# AAG USB Clone — Engineering Handoff

## 1. Purpose

This document is the durable handoff for the AAG USB Clone / Dummy USB workstream. It records why the project exists, how the accepted Linux architecture works, what failed or changed during development, how kernel and suspend integration evolved, what was actually validated, and what must never be inferred from the evidence.

The public repository is reconstructed from a sanitized publication capture made on 2026-09-15. The capture contained 35 files and explicitly excluded disk images. It combined the canonical source used by the live `dummy_hcd` self-heal installation, toolkit scripts, historical build source, installed scripts, systemd integration, profile evidence and three retained handoff/guide documents.

## 2. Problem statement

The original requirement was broader than simply creating a loopback block device. Software in a Windows/WinBoat workflow needed to observe a USB mass-storage device with a stable USB identity. A normal image mount does not reproduce the USB bus/device identity. The Linux solution therefore had to create a USB gadget and attach it to a virtual USB host controller.

The reusable solution became:

`profile -> ConfigFS gadget -> mass_storage function -> dummy UDC -> dummy_hcd host controller -> Linux USB device`

The same workstream later gained lifecycle handling, kernel-update recovery and integration guards for suspend.

## 3. Principal environment

The principal engineering workstation is one physical HP EliteBook 840 14-inch G11 configured for dual boot. Ubuntu 26.04 LTS and Windows 11 Pro run on the same physical machine. Evidence in this handoff must therefore be read by execution environment:

- **Ubuntu host:** Linux ConfigFS/dummy_hcd implementation and the accepted live services.
- **Windows physical boot:** separate Windows-native investigations and proof-of-concept work.
- **Windows guest / WinBoat:** guest visibility/passthrough workflows.
- **CI/simulation:** useful for source and policy validation, but not a substitute for physical USB acceptance.

## 4. Accepted Linux architecture

### 4.1 Profiles

The `usbclone` tool stores profiles beneath a configurable USB Clone home. A profile can preserve identity metadata and, in full-copy workflows, a backing disk image. Disk images and real captured identifiers are deliberately excluded from this public repository.

### 4.2 ConfigFS gadget

For an active profile the tool creates a gadget beneath `/sys/kernel/config/usb_gadget`, writes the USB identity/configuration, creates a `mass_storage` function, attaches the backing file and binds the gadget to a free UDC.

### 4.3 dummy_hcd

`dummy_hcd` supplies virtual USB device controllers and a virtual host-controller path. The accepted workstation uses multiple UDCs so more than one gadget can exist. The installed configuration used eight controllers during the retained acceptance period.

### 4.4 Kernel-update self-heal

A key production problem was that an externally built `dummy_hcd.ko` is kernel-specific. Copying an old module to a new kernel is not a valid update strategy: vermagic/signature compatibility matters.

The accepted self-heal design verifies a module for the target kernel, builds it against that kernel's headers when necessary, verifies vermagic, installs it under `/lib/modules/<kernel>/updates/usbclone/`, runs `depmod`, and loads it only when the target kernel is the currently running kernel. A boot-time oneshot service invokes this ensure path before optional profile activation.

The earlier toolkit installer used a safer provenance model for a clean installation: install the matching Ubuntu Linux source package, extract `drivers/usb/gadget/udc/dummy_hcd.c` from that source tarball, compile it against the running headers, and handle Secure Boot/MOK when needed. The public project should preserve that model rather than presenting a copied kernel source file as AAG code.

## 5. Provenance boundary

`dummy_hcd.c` is Linux kernel source and carries its upstream licensing/copyright. It is not AAG-authored. Historical publication-review copies are evidence of the live installation, not a basis for claiming ownership.

AAG-authored material includes the orchestration/tooling around profiles, ConfigFS, module lifecycle, service integration and acceptance/recovery logic. Any future release that vendors upstream kernel source must preserve its exact license and provenance; the preferred public design is to extract matching source from the user's installed distribution source package.

## 6. Generic vs workstation-specific integration

The generic project is USB Clone itself. Several captured production files were intentionally not copied verbatim into the public source tree because they contain workstation-specific assumptions.

Examples from the accepted machine included a profile activator with a fixed local user/home, a fixed `/mnt/data/...` profile root, a real VID:PID and a profile named for a physical Kingston device. Those values are evidence, not reusable defaults.

Similarly, the ordinary-suspend gate is coupled to the AAG T700 modem pre/post path. Its generic safety principle belongs in this documentation: do not allow ordinary suspend to proceed while an active virtual USB gadget could make teardown unsafe, and preserve fail-closed transaction identity. The exact T700 command chain belongs to the workstation integration, not the generic package.

## 7. Suspend integration

The accepted integration discovered that a virtual USB gadget can be an active consumer during suspend preparation. The production gate inventories bound ConfigFS gadgets and USB devices rooted under `dummy_hcd`.

The gate's policy is conservative:

- empty dummy controllers are allowed;
- an active USB Clone gadget is refused;
- an unmanaged bound ConfigFS gadget is refused;
- an orphan dummy_hcd USB device without a ConfigFS owner is refused.

The retained self-test also verifies transaction handling so a refused pre phase does not falsely run the paired modem post phase. This is integration evidence, not a requirement for users who do not use the AAG suspend/T700 stack.

## 8. Historical Windows / WinBoat work

The engineering history contains Windows-native USB/IP/virtual-device investigations as well as WinBoat/QEMU guest passthrough. They must not be merged conceptually with the Linux ConfigFS implementation.

The latest retained system handoff treats the validated QMP passthrough baseline as stronger evidence than a later Compose/QEMU permanent-injection experiment that remained transitional and required re-verification. Future documentation must preserve that distinction.

No proprietary Windows application, third-party binary, captured private device image or licensed data belongs in this repository.

## 9. Privacy sanitization performed for publication

The 2026-09-15 review archive was **not** published verbatim. The public source intentionally excludes:

- raw disk images;
- real USB serial numbers;
- binary descriptor captures from real devices;
- raw `udev`, `lsusb -v`, `lsblk` and partition dumps tied to real devices;
- fixed local usernames and home paths;
- `/mnt/data/...` workstation paths;
- device-specific activation scripts with real identity values;
- private or proprietary application/data artifacts.

Public examples must use synthetic identities.

## 10. Validation evidence

The publication capture itself passed the following capture gates:

- canonical `dummy_hcd` source used by the live self-heal path present;
- 6 toolkit files captured;
- 3 historical-build files captured;
- 4 installed implementation files captured;
- 3 systemd integration files captured;
- 3 documentation files captured;
- no disk image included;
- live system not modified by capture;
- archive integrity verified.

The broader inventory immediately before publication review also showed the virtual USB stack active on Ubuntu kernel `7.0.0-31-generic`, with `dummy_hcd` loaded, multiple dummy UDCs available and the accepted virtual mass-storage profile visible on the USB bus.

These facts do **not** prove that a newly cloned public repository has been installed clean-room on arbitrary hardware. A release must not claim that until a public installer is reconstructed and tested independently.

## 11. Known gaps at initial publication

1. The public installer must be reconciled from the retained toolkit and current self-heal logic.
2. The complete 687-line installed `usbclone` command must be privacy/provenance reviewed before being published verbatim.
3. Public synthetic fixtures must replace real profile captures.
4. CI can test shell syntax, policy and fixture parsing but cannot prove real ConfigFS/UDC behavior on GitHub-hosted runners.
5. Windows-native proof-of-concept source requires separate provenance review before publication.
6. WinBoat/Otzar integration should be documented as optional integration and must not publish third-party code/data.

## 12. Recovery and rollback principles

- Do not delete user profile storage during uninstall by default.
- Do not copy a `dummy_hcd.ko` built for another kernel.
- Preserve the previous module as a timestamped backup before replacing a production external module.
- Verify target-kernel headers and module vermagic before installation.
- Keep optional workstation-specific activation separate from the generic boot-time module ensure service.
- When an active gadget is part of a larger suspend workflow, fail closed rather than pretending teardown succeeded.

## 13. Repository maintenance rule

Every material change must update this handoff when it changes architecture, validation, installation, privacy boundaries, kernel behavior, Windows/WinBoat integration or known limitations. Historical failures must remain documented when they explain why the accepted architecture exists.

## 14. Publication state

Initial public classification: **SANITIZED SOURCE-RECONCILIATION PREVIEW**.

The repository is suitable for preserving the engineering story and sanitized reusable components. It must not be called a clean-room production release until the reconstructed public installer/tooling is tested independently from the private workstation installation.