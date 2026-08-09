# Handoff

Updated: 2026-08-09
Branch: `project-continuity-docs`
Relevant baseline: `a2e1153` (`Package universal Intel Sender distribution`)

**Goal:** move the isolated universal Sender work onto upstream `v3.4.2`, then
re-validate it before preparing another prerelease.

**Completed:** universal `3.3.0-intel.2` local candidate; 83 x86_64 Sender tests
passed; package slice/signature/checksum checks completed; native Apple Silicon
Sender streaming was exercised against an Intel Receiver.

**Current state:** continuity documentation is established; the Receiver remains
unchanged; no new public release should be prepared from this baseline.

**Start with:** [PROJECT_STATE.md](PROJECT_STATE.md), then create a clean
integration branch from upstream `v3.4.2` and port Sender changes in small
groups.

**Caution:** do not stage the existing local modification to
`TargetBridge-Sender/TargetBridge.xcodeproj/xcshareddata/xcschemes/TBDisplaySender.xcscheme`.
Preserve the isolated Sender identity, Receiver boundary and no-network-change
behavior.
