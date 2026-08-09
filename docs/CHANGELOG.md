# Changelog

This file records significant fork changes. Detailed implementation history is
maintained in Git; installation and packaging details remain in the release
notes.

## Unreleased

### Documentation

- Added a compact project overview, operational state, architecture, decisions,
  roadmap and handoff documentation to preserve continuity between releases.

## 3.3.0-intel.2 — local universal prerelease candidate

### Changed

- Produced an isolated universal Sender package containing `x86_64` and
  `arm64` executable slices.
- Added local artifact archival, ZIP/DMG/checksum validation and universal
  package verification.

### Validation

- Completed the x86_64 Sender suite with 83 passing tests.
- Verified native Apple Silicon Sender operation against an Intel Receiver.

This candidate was not promoted as the next public release baseline; see
[Release 3.3.0-intel.2](Release-3.3.0-intel.2.md) and
[Project state](PROJECT_STATE.md).

## 3.3.0-intel.1 — Intel Sender prerelease

### Added

- Separately identified Intel Sender packaging and safe uninstall support.
- 4K-oriented profiles, Intel VideoToolbox diagnostics and compatibility
  reporting.
- Sender UI, localization, menu and launch-behavior adaptations documented in
  the project guides.

### Preserved

- Original TargetBridge attribution, license, protocol and Receiver source.
