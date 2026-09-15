# Development History

## Early requirement

The project began from a practical need to reproduce a USB mass-storage device in software closely enough that downstream software/guest workflows could observe a USB device rather than merely a mounted filesystem image.

## Linux virtual USB direction

The accepted Linux direction combined ConfigFS mass-storage gadgets with the kernel `dummy_hcd` virtual host/device-controller infrastructure. The toolkit grew commands for scanning, capture, profile storage, start/stop, import/export, diagnostics and cleanup.

## Identity-only vs full capture

The toolkit distinguished identity-oriented profiles from full-copy profiles. Full copy requires safe unmounting and creates a potentially large backing image. Those runtime images are not source artifacts and are intentionally absent from GitHub.

## Kernel compatibility work

A major reliability issue was surviving kernel changes. Historical build material shows kernel-specific external builds, while the later accepted production path added a target-kernel self-heal operation with header and vermagic verification. The earlier clean installer also demonstrated the preferred provenance method of extracting `dummy_hcd.c` from the installed Ubuntu Linux source package.

## Secure Boot

The toolkit installer included Secure Boot detection and MOK signing/enrollment handling for externally built modules. This became part of the installation requirements rather than treating a successful compile as sufficient.

## WinBoat / Windows integration

The virtual USB device was used in a larger Windows/WinBoat engineering program. Guest passthrough and Windows-native USB/IP experiments were explored. These are kept historically distinct from the Linux gadget implementation. The latest retained handoff gives stronger status to the validated QMP passthrough baseline than to a later permanent Compose/QEMU injection experiment that still required re-verification.

## Suspend interaction

Once USB Clone became part of the production workstation, suspend safety became relevant. An AAG ordinary-suspend gate was added to inventory bound ConfigFS gadgets and dummy_hcd devices and refuse unsafe transitions. That gate later became coupled to the workstation's T700 modem lifecycle, so the public USB Clone project records the policy but does not pretend the whole workstation-specific chain is generic.

## 2026-09-15 portfolio reconciliation

A portfolio-wide audit discovered that USB Clone/Dummy USB was a substantial active project that had never received its own public repository. A read-only publication capture collected 35 source/evidence files and explicitly rejected disk images. Review found real serial numbers, descriptors and private paths in profile/activation evidence, so the project was classified `SANITIZE THEN PUBLIC`.

The public repository was then initialized from the sanitized engineering record rather than uploading the private source capture wholesale.