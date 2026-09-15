# Installation and Kernel Compatibility

## Current publication status

The original toolkit installer and the later production self-heal implementation are both preserved in the private publication evidence. They are being reconciled before a public production installer is declared supported.

Do not treat this repository's initial documentation-only state as a production installer release.

## Required Linux facilities

The accepted Ubuntu implementation used:

- ConfigFS;
- `libcomposite`;
- `usb_f_mass_storage`;
- `dummy_hcd`;
- matching Linux headers;
- Linux source when `dummy_hcd` must be built externally;
- `usbutils`, `udev`, `util-linux` and filesystem/image tooling used by capture workflows.

## Correct `dummy_hcd` provenance model

The retained toolkit installer followed this sequence:

1. Determine the running kernel and corresponding Ubuntu Linux source package.
2. Prefer a suitable official `dummy_hcd` already supplied for that kernel when available.
3. Otherwise extract `drivers/usb/gadget/udc/dummy_hcd.c` from the installed Linux source tarball.
4. Compile it against `/lib/modules/$(uname -r)/build`.
5. Verify module vermagic matches the target kernel.
6. When Secure Boot is enabled, sign the module using the system MOK workflow and require enrollment where necessary.
7. Install the external module under `/lib/modules/<kernel>/updates/usbclone/` and run `depmod`.

This avoids pretending that the upstream kernel source is AAG-authored and avoids blindly reusing a module built for a different kernel.

## Multiple UDCs

The accepted workstation configured `dummy_hcd` with multiple controllers (`num=8`) to support multiple virtual gadgets. The correct count is deployment-specific and should be configurable rather than hard-coded.

## Kernel updates

A production deployment should run a target-kernel ensure operation after kernel/header installation and before optional profile activation. The accepted self-heal path validates headers and vermagic and can prepare a module for a kernel other than the currently running kernel without attempting to load that module.

## Secure Boot

An externally built kernel module may require signing and MOK enrollment. A public installer must detect Secure Boot and fail clearly rather than silently leaving an unloadable module.

## Uninstall principle

Uninstall should remove project-installed commands/configuration/modules, run `depmod`, and leave the user's profile repository intact unless the user explicitly requests profile deletion.