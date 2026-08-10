# Handoff

Updated: 2026-08-10
Branch: `legacy-sender`
Relevant baseline: `611ff8e` (`Support macOS 12.3 Sender probe`)

**Goal:** publish the experimental macOS 12.3+ legacy Sender line, then move
the maintained work onto upstream `v3.4.2`.

**Completed:** x86_64 build with minimum macOS 12.3; real Monterey Intel probe;
virtual display creation; TCP connection to the unchanged Receiver; session
audio control hidden on macOS 12 while Audio Relay remains listed as an add-on.

**Current state:** legacy branch is ready for an explicitly labelled prerelease;
the Receiver remains unchanged and the build is ad-hoc signed.

**Start with:** publish the legacy branch/tag, then create a clean integration
branch from upstream `v3.4.2` and port Sender changes in small groups.

**Caution:** do not stage the existing local modification to
`TargetBridge-Sender/TargetBridge.xcodeproj/xcshareddata/xcschemes/TBDisplaySender.xcscheme`.
Preserve the isolated Sender identity, Receiver boundary and no-network-change
behavior.
