# Changelog

This file records significant fork changes. Detailed implementation history is
maintained in Git; installation and packaging details remain in the release
notes.

## Unreleased

### Documentation

- Added a compact project overview, operational state, architecture, decisions,
  roadmap and handoff documentation to preserve continuity between releases.

## 3.3.0-intel-legacy.1 — experimental legacy prerelease

### Added

- Intel x86_64 Sender compatibility changes for a macOS 12.3 deployment target.
- Availability gates for macOS 12 APIs and frameworks used by the Sender.
- Real Monterey Intel probe evidence for virtual-display creation and TCP
  connection to the unchanged Receiver.

### Changed

- The session-level system-audio control is hidden on macOS 12 because native
  ScreenCaptureKit audio capture is unavailable there.
- The Audio Relay add-on remains listed for later evaluation; it is not removed
  or claimed as supported by this legacy session path.

### Limitations

- Experimental, x86_64-only, ad-hoc signed and not notarized.
- End-to-end long-duration video acceptance on the physical Monterey pair is
  still pending.

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
