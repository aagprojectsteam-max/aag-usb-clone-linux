# Troubleshooting

## `dummy_hcd` not found

Check whether the running kernel already provides it with `modinfo dummy_hcd`. If not, install matching kernel headers and Linux source and build the matching source. Do not copy a module from another kernel.

## Vermagic mismatch

A module built for a different kernel must not be treated as compatible. Rebuild against `/lib/modules/<target>/build`, verify `modinfo -F vermagic`, install under the target kernel's module tree, then run `depmod`.

## Module will not load with Secure Boot

Check Secure Boot state and kernel logs. Externally built modules may require signing with an enrolled MOK. A successful compile does not prove the kernel will accept the module.

## `dummy_hcd` loaded but no UDC exists

Inspect `/sys/class/udc`, module parameters and kernel logs. The accepted production self-heal treats zero UDCs after loading `dummy_hcd` as an error rather than success.

## No free UDC

A gadget must bind to an unused UDC. Inspect existing ConfigFS gadgets and their `UDC` attributes. Do not steal a controller from an active gadget.

## Gadget appears but backing storage is wrong

Stop the gadget before changing the backing file. Confirm the profile points to the intended image and that the image is not being concurrently modified in an unsafe way.

## Physical device and clone share the same identity

Do not normally leave the original physical USB device connected while starting a clone with the same identity. Identity collisions make diagnostics ambiguous and may confuse consumers.

## Suspend is refused

On the accepted AAG workstation this can be intentional: the ordinary-suspend gate refuses when a bound virtual USB gadget or orphan dummy_hcd-backed device is active. Stop the clone cleanly before retrying suspend. The exact T700-coupled gate is workstation-specific and is not a generic project dependency.

## Kernel update broke USB Clone

Verify matching headers are installed for the new kernel, run/reconstruct the target-kernel ensure operation, verify module vermagic, run `depmod`, and only then load the module. Preserve the previous external module as rollback evidence rather than overwriting it blindly.