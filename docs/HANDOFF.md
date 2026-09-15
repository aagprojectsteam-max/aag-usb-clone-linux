# AAG USB Clone / Dummy USB — Complete Engineering Handoff

> Durable end-to-end engineering record. This document is intentionally long. It is meant to let a future maintainer understand why the project exists, what was tried, what failed, what was accepted, how the production machine was configured, what evidence exists, what remains unverified, and how to continue without relying on chat history.

## 1. Executive summary

AAG USB Clone grew from a practical requirement: software running in Windows/WinBoat needed to observe a USB mass-storage device as a USB device, not merely see files mounted from an image. A normal loop mount reproduces storage contents but not USB bus identity. The Linux solution therefore creates a USB gadget through ConfigFS, attaches a mass-storage backing file, binds it to a virtual USB device controller supplied by `dummy_hcd`, and lets Linux enumerate the resulting gadget through a virtual host-controller path.

The accepted reusable Linux architecture is:

`profile -> ConfigFS USB gadget -> mass_storage function -> dummy UDC -> dummy_hcd host controller -> enumerated Linux USB device`

The project subsequently acquired profile capture/import/export, multi-controller support, kernel-update recovery, Secure Boot considerations, systemd lifecycle, optional profile activation, suspend safety and WinBoat/QEMU integration work.

This public repository was reconstructed from a publication-review capture made on 2026-09-15. The capture contained 35 files and deliberately excluded disk images. It included the canonical source used by the live `dummy_hcd` self-heal installation, toolkit material, historical build source, current installed scripts, systemd integration, profile evidence and three retained handoff/guide documents. The capture was evidence for reconstruction; it was **not** published verbatim because it contained machine/device-specific material.

Initial public state remains **SANITIZED SOURCE-RECONCILIATION PREVIEW** until a clean public installer/toolset is independently installed and accepted.

## 2. What problem were we actually solving?

The requirement was not simply “make a virtual disk.” The target workflow needed USB semantics. In particular, a mounted image, loop device, ordinary file share or Windows-visible directory is not equivalent to a USB mass-storage device. Software may care about enumeration, USB descriptors, VID/PID, serial identity, removable-device behavior or guest passthrough.

The engineering problem therefore had several layers:

1. preserve or define a USB device identity;
2. provide storage contents through a backing file;
3. expose both through a USB gadget;
4. provide a virtual UDC/host path on a machine with no physical gadget controller suitable for this use;
5. keep the arrangement recoverable across kernel updates;
6. integrate safely with boot, shutdown and suspend;
7. optionally pass the resulting device into a Windows/WinBoat guest;
8. avoid turning private captured device material into public source.

## 3. Principal development and validation environment

The principal workstation is one physical **HP EliteBook 840 14-inch G11** configured for **dual boot**. Ubuntu 26.04 LTS and Windows 11 Pro run on the same physical computer. This distinction matters throughout the evidence.

### Ubuntu host

The accepted Linux ConfigFS/`dummy_hcd` implementation, current services, kernel self-heal and suspend integration were developed and validated here. The publication-era inventory observed Ubuntu kernel `7.0.0-31-generic` with `dummy_hcd` loaded and multiple dummy UDCs available.

### Windows physical boot

Separate Windows-native USB/IP/virtual-device experiments existed. They are historically related but are **not the same implementation** as the Linux ConfigFS stack.

### Windows guest / WinBoat

The project was also used with Windows running through WinBoat/QEMU. USB passthrough into that guest is an integration layer above USB Clone; it is not part of the fundamental gadget implementation.

### CI

GitHub Actions can validate publication hygiene, documentation, shell/source structure and synthetic fixtures. GitHub-hosted CI must not be represented as physical ConfigFS/UDC/USB acceptance.

## 4. Terminology

- **USB Clone** — AAG orchestration/tooling for representing a profile as a virtual USB gadget.
- **Dummy USB** — informal project/workstream name used during development.
- **profile** — metadata describing a USB identity/configuration and, for full-copy workflows, a storage backing image.
- **ConfigFS** — Linux interface used to construct USB gadgets.
- **UDC** — USB Device Controller. The virtual UDCs here are supplied by `dummy_hcd`.
- **dummy_hcd** — upstream Linux kernel dummy host/device-controller driver used as the virtual USB transport.
- **backing image** — file exposed through the gadget mass-storage function. Real images are runtime/private data and are not part of this repository.

## 5. Architecture from the bottom up

### 5.1 Backing storage

A full USB clone may use a disk image as the storage backend. Such images can be very large and may contain copyrighted, proprietary or personal data. They are runtime artifacts, not source code. The local inventory contained large image files; publication capture intentionally excluded them.

### 5.2 Profiles

The toolkit supports profile-oriented operation. A profile can carry identity/configuration information and point to a backing image. Development evidence included profiles derived from real devices. Those raw profiles were useful for acceptance but are not suitable public examples because they can expose real serial numbers, descriptors and workstation paths.

Public examples must therefore be synthetic. Users who capture their own device information are responsible for their own data and legal/licensing constraints.

### 5.3 ConfigFS gadget construction

For an active profile, the orchestration layer creates a gadget under `/sys/kernel/config/usb_gadget`, writes USB identity/configuration values, creates a `mass_storage` function, associates the backing file, links the function into a configuration and binds the gadget to a free UDC.

This is the point at which profile metadata and backing storage become a USB gadget.

### 5.4 Virtual USB transport: dummy_hcd

Most ordinary PCs are not USB gadget devices. `dummy_hcd` provides a virtual environment containing dummy UDCs and host-controller behavior. USB Clone uses those UDCs to bind ConfigFS gadgets so Linux can enumerate them as USB devices.

The accepted workstation configuration used multiple controllers; the retained inventory observed eight dummy UDCs. Multi-controller support matters because one bound gadget consumes a UDC and multiple gadgets may coexist.

### 5.5 Enumeration

After binding, the host side sees a USB device rather than merely a mounted image. That distinction is the core reason this architecture exists.

## 6. The `usbclone` toolkit

The retained toolkit and installed command show that the project evolved beyond a one-off script. The command surface included profile-oriented operations such as capture, import/export, start/stop and management of ConfigFS/dummy UDC resources.

The publication review captured the installed command, but the complete installed script is not automatically treated as publishable merely because it exists. Before verbatim publication it must pass privacy/provenance review, because operational scripts can embed assumptions about local paths, profile names or captured identities.

The public reconstruction should preserve behavior while making configuration explicit and portable.

## 7. Kernel-source provenance — critical rule

`dummy_hcd.c` is **not AAG-authored code**. It is Linux kernel source with upstream copyright/licensing. A copied source file from the production machine is evidence of what was built, not something AAG can present as original source.

The earlier toolkit installer used the better clean-install provenance model:

1. obtain the matching Ubuntu/Linux source package;
2. extract `drivers/usb/gadget/udc/dummy_hcd.c` from that source;
3. build against the target/running kernel headers;
4. preserve upstream licensing and copyright;
5. handle Secure Boot signing when required.

That is the preferred public installation strategy. If any future release vendors upstream kernel source, its exact provenance/license must be retained and clearly separated from AAG-authored orchestration.

## 8. Why kernel updates became a production problem

An externally compiled `.ko` is kernel-specific. A module that worked on one kernel cannot safely be copied into a newer kernel merely because the filename is the same. Kernel ABI/build configuration and `vermagic` matter; Secure Boot may add signing requirements.

This led to the kernel self-heal design.

## 9. Accepted kernel self-heal design

The production design treats the target kernel as an explicit build target:

1. determine the target kernel;
2. verify the target kernel headers exist;
3. inspect whether a suitable external `dummy_hcd` module already exists;
4. verify module metadata/vermagic;
5. if missing/incompatible, compile from the approved matching source;
6. place the module under `/lib/modules/<kernel>/updates/usbclone/`;
7. run `depmod`;
8. load the module only when the target is the currently running kernel;
9. keep boot-time module ensure separate from optional device/profile activation.

This avoids the dangerous shortcut of copying a stale module between kernels.

A systemd oneshot service invokes the ensure path during boot. The retained production capture included both the ensure script and the service definition.

## 10. Secure Boot / MOK considerations

The historical toolkit included Secure Boot/MOK handling because an externally built module may be rejected when Secure Boot enforcement is active. Signing material is machine/security-sensitive and must not be committed to a public repository.

A public installer may support signing, but it must generate/use local signing material and explain enrollment rather than shipping private keys or workstation certificates.

## 11. Boot lifecycle

The production arrangement separated two concerns:

- ensure that the kernel has a compatible `dummy_hcd` implementation;
- optionally activate a chosen USB Clone profile.

That separation is important. A generic installation should not assume that every boot must expose one specific captured device. Workstation-specific activation can depend on local profile names, local storage paths and a particular application workflow.

The public project should therefore install generic capability first and make automatic profile activation opt-in.

## 12. Workstation-specific activation discovered during publication review

The captured production activation service/script included assumptions specific to the accepted workstation, including a fixed user/home, a fixed `/mnt/data/...` USB Clone storage location, a profile associated with a physical Kingston device and a real USB identity.

Those details are **evidence of the deployment**, not public defaults. They were intentionally not copied verbatim into the sanitized source tree.

Public configuration must use placeholders/synthetic identities and configurable paths.

## 13. Suspend integration

USB Clone eventually interacted with the wider AAG suspend-safety architecture. A bound virtual gadget is a real active consumer from the perspective of lifecycle management; suspending or tearing down related storage while a gadget remains active can be unsafe.

The production ordinary-suspend gate therefore inventories ConfigFS/dummy_hcd state.

Accepted conservative policy:

- empty dummy controllers are allowed;
- a bound managed USB Clone gadget causes refusal when the surrounding workflow requires it to be inactive;
- an unmanaged bound ConfigFS gadget causes refusal;
- an orphan USB device rooted under `dummy_hcd` without an identifiable ConfigFS owner causes refusal.

The retained integration also protected transaction pairing so a failed/refused pre phase could not incorrectly trigger the paired modem post phase.

### Important boundary

The captured gate was integrated with the AAG T700 modem/suspend system. That exact dependency is **not** a generic USB Clone requirement. The reusable concept is lifecycle awareness and fail-closed safety; the T700 command chain belongs to the workstation integration.

## 14. Relationship to the external-storage safe-suspend project

USB Clone and the external-storage safe-suspend project are separate projects with an integration boundary. USB Clone may consume backing storage; the suspend project protects storage/power-state transitions. Documentation should cross-reference the integration but should not duplicate or merge the two codebases.

## 15. WinBoat / Windows guest integration

A major practical use case involved making the virtual USB device available to a Windows guest running through WinBoat/QEMU.

Historical work included QMP/QEMU passthrough and later experiments with more permanent Compose/QEMU injection. The newest retained system-level handoff gives stronger acceptance status to the QMP passthrough baseline; the later permanent-injection experiment was transitional and required re-verification.

Therefore the durable rule is:

**Do not rewrite history to make the later experiment the accepted baseline unless new evidence validates it.**

WinBoat/Otzar integration is optional and layered above the generic Linux USB Clone implementation.

## 16. Windows-native workstream

There was also a separate Windows-native USB/IP/virtual-device proof-of-concept/workstream. It must remain conceptually distinct from Linux USB Clone.

Reasons:

- different operating-system architecture;
- different driver/tool provenance;
- potentially different licensing/upstream source;
- different acceptance evidence;
- Windows physical boot is not WinBoat guest execution.

The Windows-native source should only be published after an independent provenance audit. It must not be silently folded into this repository as though it were AAG-authored Linux code.

## 17. Dual-boot evidence rule

Because Ubuntu and Windows run on the **same physical computer**, statements such as “tested on Linux and Windows” can be misleading unless the execution environment is specified.

Every future validation should use one of these labels:

- `UBUNTU_PHYSICAL_HOST`
- `WINDOWS_PHYSICAL_BOOT`
- `WINDOWS_WINBOAT_GUEST`
- `CI_SIMULATION`

Dual boot is useful for cross-OS development, but it is not evidence of two independent hardware platforms.

## 18. Historical evolution and major engineering lessons

### Stage A — need for USB identity

The project began when ordinary storage/image presentation was insufficient. The requirement was elevated from “make data visible” to “make a USB device visible.”

### Stage B — ConfigFS + dummy_hcd architecture

ConfigFS supplied gadget composition and `dummy_hcd` supplied virtual UDC/host behavior. This became the reusable Linux architecture.

### Stage C — profiles/toolkit

The solution grew into profile-based tooling rather than one hard-coded gadget. Capture/import/export/start/stop concepts made the work reusable.

### Stage D — production identity/profile activation

A real device-derived profile was used in the accepted workstation workflow. This was useful for proving the practical requirement but later became an important publication/privacy boundary.

### Stage E — kernel-update failure mode

Kernel-specific external module behavior demonstrated that copying an old `.ko` forward is not a valid maintenance strategy.

### Stage F — self-healing module lifecycle

The project gained target-kernel build/verification, `vermagic` checking, installation under `updates/usbclone`, `depmod` and boot-time ensure behavior.

### Stage G — suspend safety

The virtual gadget became part of broader lifecycle reasoning. Active/unmanaged/orphan gadget states had to be detected rather than ignored during suspend preparation.

### Stage H — Windows/WinBoat integration

Guest passthrough work demonstrated the end-to-end use case. A validated QMP path existed; later permanent-injection experiments were not automatically promoted to canonical status.

### Stage I — publication reconstruction

On 2026-09-15 the broader AAG GitHub audit discovered that Dummy USB/USB Clone was a substantial project missing from the public portfolio. A read-only source capture was made specifically to reconstruct a safe public repository.

## 19. Publication capture — exact evidence boundary

The successful V2 capture reported:

- `CAPTURE=PASS`
- `VERSION=V2`
- 35 files total;
- archive size approximately 144 KiB;
- canonical `dummy_hcd` source present;
- 6 toolkit files;
- 3 historical-build files;
- 4 installed implementation files;
- 3 systemd files;
- 3 documentation files;
- no disk images;
- live system not modified.

The capture was intentionally small because huge runtime disk images were excluded.

## 20. Why the first capture was rejected

The first publication-capture script printed `CAPTURE=PASS` even though three `cp --parents` operations failed. The failures occurred inside `find -exec`; the shell's `set -e` behavior did not turn that into the intended top-level failure.

This is an important engineering lesson: **a success banner is not evidence unless required artifacts are explicitly checked.**

The V2 capture corrected this by:

- copying through controlled helper functions;
- checking the canonical source explicitly;
- counting toolkit/historical/installed/systemd/documentation files;
- refusing to create an archive when required categories were absent;
- explicitly scanning for forbidden image formats;
- validating the final tar archive.

The flawed first archive was not used as the publication source.

## 21. Privacy review findings

The V2 capture was suitable for private review but still not safe to publish verbatim. Review found real-device and workstation-specific information, including combinations of:

- USB serial numbers;
- real VID/PID identity;
- descriptor data;
- `udev` evidence;
- `lsusb -v` evidence;
- partition/`lsblk` evidence;
- local usernames/home assumptions;
- `/mnt/data/...` paths;
- real profile names;
- application-specific activation assumptions.

Therefore the repository uses sanitized/synthetic examples rather than publishing raw capture material.

## 22. What must never be committed

Do not commit:

- real disk/backing images (`*.img`, `*.raw`, `*.iso`, `*.vhd*`, `*.qcow2`);
- real captured device serials unless intentionally public and reviewed;
- raw descriptor/udev/partition dumps from private devices;
