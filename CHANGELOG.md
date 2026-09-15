# Changelog

## Unreleased — source-reconciliation preview

- Created the first dedicated public repository for the AAG USB Clone / Dummy USB workstream.
- Added a long-form engineering handoff, architecture, installation/kernel, testing, troubleshooting, security/provenance and history documentation.
- Recorded the Ubuntu/Windows dual-boot development environment without treating dual boot as cross-platform validation.
- Explicitly separated generic Linux USB Clone architecture from workstation-specific profile activation, T700/suspend wiring and Windows/WinBoat integrations.
- Excluded real device serials, raw descriptor/udev captures, disk images and private workstation paths from publication.
- Recorded Linux `dummy_hcd` as upstream kernel source rather than AAG-authored code.

### Not yet a production release

The public installer and complete live `usbclone` command remain under source reconciliation/privacy review. No clean-room release acceptance is claimed yet.