# Project state

Updated: 2026-08-10

## Current baseline

The active branch is `legacy-sender`, based on the Intel Sender fork at parent
commit `a2e1153` (`Package universal Intel Sender distribution`). This branch
is an experimental compatibility line for Intel Sender builds on macOS 12.3+.

The main fork candidate remains `3.3.0-intel.2`, a universal Sender with an
isolated application identity. The legacy candidate is `3.3.0-intel-legacy.1`:
x86_64, minimum macOS 12.3, with no session-level system-audio control. The
next long-term integration target remains upstream TargetBridge `v3.4.2`.

## Implemented and verified

- Isolated Sender identity: `TargetBridge Intel Sender.app`, separate bundle
  identifier, URL scheme, preferences, support data, logs and uninstall path.
- Universal Sender packaging with `x86_64` and `arm64` executable slices.
- Intel-oriented 4K profiles and VideoToolbox diagnostics.
- Read-only Thunderbolt Bridge and link-local Ethernet selection support.
- Sender menu, localization, launch behavior, diagnostics and telemetry
  improvements described in the maintained user documentation.
- The original Receiver remains unmodified.

The local x86_64 Sender test suite completed with 83 passing tests. The
universal package was checked for both architecture slices, ad-hoc signature,
ZIP/DMG contents and checksums. A native Apple Silicon Sender session has also
been exercised against an Intel Receiver. These results apply to the documented
candidate and must be repeated after the upstream integration.

## Constraints and open items

- Local packages are ad-hoc signed and are not Developer ID signed or
  notarized.
- Long-duration compatibility, sleep/wake and additional hardware-pair testing
  remain incomplete.
- There is no separate Receiver variant yet; Receiver modernization is future
  work and must preserve protocol compatibility.
- A pre-existing local modification to
  `TargetBridge-Sender/TargetBridge.xcodeproj/xcshareddata/xcschemes/TBDisplaySender.xcscheme`
  is outside this documentation task and must remain excluded from its commits.
- The Audio Relay add-on remains in the catalogue for future work; it is not
  claimed as supported by the macOS 12 legacy session path.

## Immediate next work

1. Run the complete physical Monterey Sender/Receiver stream, reconnect and
   sleep/wake checks against the published legacy prerelease.
2. Create a clean integration branch from upstream `v3.4.2` and port the
   isolated Sender changes in reviewable groups.
3. Re-run the Sender test suite, universal build checks and representative
   Intel/Apple Silicon acceptance tests on the integrated result.

Detailed historical observations remain in [Intel Sender audit](Intel-Sender-Audit.md),
[Compatibility](Compatibility.md) and the `Release-3.3.0-intel.*` notes.
