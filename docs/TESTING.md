# Testing and Evidence

## Publication capture — 2026-09-15

The source-review capture passed with:

```text
CAPTURE=PASS
VERSION=V2
FILES=35
ARCHIVE_SIZE=144K
DISK_IMAGES_INCLUDED=NO
LIVE_SYSTEM_MODIFIED=NO
```

Required-source checks reported:

```text
PASS: canonical dummy_hcd source
TOOLKIT_FILES=6
HISTORICAL_BUILD_FILES=3
INSTALLED_FILES=4
SYSTEMD_FILES=3
DOCUMENTATION_FILES=3
```

The capture was intentionally read-only with respect to the live USB Clone installation.

## Live-system evidence

The preceding portfolio inventory found the accepted Ubuntu stack active on kernel `7.0.0-31-generic`: `dummy_hcd` was loaded, dummy UDC controllers were present, and the accepted virtual mass-storage profile enumerated on the Linux USB bus.

## Retained suspend-gate self-tests

The captured ordinary-suspend integration includes tests for these policy conditions:

- empty dummy controllers allowed;
- bound project USB Clone gadget refused;
- backing file reported in inventory;
- unmanaged bound ConfigFS gadget refused;
- orphan dummy_hcd device refused;
- active-clone pre phase returns refusal code;
- refused pre transaction causes paired post integration to be skipped and archived as such.

Those tests validate policy logic. They do not independently validate a generic public installer.

## Evidence limits

Initial publication does **not** claim:

- clean-room installation from this public repository;
- compatibility with every Ubuntu/kernel release;
- physical-Windows native virtual USB acceptance from this Linux repository;
- arbitrary Windows guest/WinBoat compatibility;
- reproduction of every property of every physical USB device;
- that private profile captures are safe to publish.

## Release acceptance gate

Before the first production release, require at minimum:

1. shell/static checks for all public scripts;
2. privacy scan for local usernames, private mount paths, serial numbers and captured device dumps;
3. clean Ubuntu install on a system without the private workstation installation;
4. matching-kernel `dummy_hcd` build/vermagic validation;
5. ConfigFS gadget create/start/stop cycle;
6. reboot persistence/self-heal test;
7. kernel-update test;
8. Secure Boot path where practical;
9. uninstall test proving user profiles are preserved;
10. optional guest passthrough acceptance documented separately from core Linux acceptance.