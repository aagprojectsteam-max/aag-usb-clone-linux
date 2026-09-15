# Architecture

## Data path

```text
USB Clone profile
  -> ConfigFS usb_gadget
  -> mass_storage function
  -> dummy UDC
  -> dummy_hcd virtual host controller
  -> Linux USB enumeration
  -> optional guest passthrough
```

A profile contains the values needed to construct a gadget. Full-copy profiles additionally refer to a local backing image; those images are user data and are never part of the source repository.

## Components

### `usbclone`

The retained production command implements profile creation, device scanning, safe unmounting, identity/full capture, gadget start/stop, legacy cleanup, import/export and diagnostics. Publication of the complete live command is gated on final privacy/provenance review.

### ConfigFS

The runtime mounts ConfigFS if needed, loads `libcomposite` and `usb_f_mass_storage`, creates a project-owned gadget and binds it to an unused UDC.

### `dummy_hcd`

The Linux kernel's `dummy_hcd` provides virtual device controllers. It is upstream Linux code, not AAG code. The public install path should extract the matching source from the distribution's Linux source package when the running kernel does not already provide a usable module.

### Kernel self-heal

A target-kernel ensure operation checks `/lib/modules/<K>/build`, verifies installed module vermagic, builds a matching external module when required, installs it under `updates/usbclone`, runs `depmod`, and only loads it when `<K>` equals the running kernel.

### Optional profile activation

The accepted workstation had a boot service that activated one specific virtual device. That service contained real workstation paths and USB identity values and is intentionally not a generic component.

### Optional suspend gate

The accepted workstation also used a fail-closed ordinary-suspend gate. The gate detects active bound gadgets and dummy_hcd-backed devices and can veto suspend preparation. Its production implementation is coupled to another AAG subsystem, so the generic repository documents the contract rather than shipping that exact machine-specific drop-in by default.

## Trust boundaries

Source code and reusable scripts are repository material. Device captures, disk images, real serials, private paths, third-party applications and proprietary content are runtime/private material.

## Windows boundary

Physical-Windows USB/IP experiments and WinBoat/QEMU guest passthrough are separate layers. They may consume the virtual USB device exposed by Linux, but they are not the Linux USB Clone implementation itself.