# Decisions

## 2026-07-31 — Keep the Intel Sender isolated from upstream installations

**Context.** The Sender needed to coexist with an original TargetBridge
installation and an unchanged Receiver.

**Decision.** Use a distinct app name, bundle identifier, URL scheme,
preferences, support data, logs and uninstall targets for the Intel Sender.

**Consequences.** The variant can be installed and removed independently. It
must preserve the original license and attribution, and it must not claim the
unchanged Receiver as fork-specific work.

## 2026-07-31 — Prefer hardware VideoToolbox with explicit diagnostics

**Context.** Intel hardware support could not be inferred safely from source
alone.

**Decision.** Build and probe the Sender on Intel hardware, require hardware
VideoToolbox sessions for normal H.264/HEVC operation, and report encoder and
fallback state at runtime.

**Consequences.** 4K profiles use HEVC where compatible and can fall back to
H.264. Capability probes prove session availability, not end-to-end quality;
acceptance tests remain required.

## 2026-07-31 — Keep network management outside the application

**Context.** The Sender must use Thunderbolt Bridge or Ethernet without
surprising changes to a user's network environment.

**Decision.** Discover and bind the selected local interface only. Do not
assign addresses, modify routes, disable Wi-Fi or bond multiple Thunderbolt
cables.

**Consequences.** The user controls network configuration. Each display stream
uses one TCP connection over one selected interface.

## 2026-08-02 — Package the Sender as universal while retaining Intel focus

**Context.** Native Apple Silicon Sender testing showed that a separately
identified package could serve both architectures without Rosetta.

**Decision.** Produce a universal Sender (`x86_64` and `arm64`) while retaining
the Intel Sender name to describe the fork's compatibility goal, isolation and
diagnostic focus.

**Consequences.** Every release candidate must validate both binary slices and
must not imply that all Sender/Receiver hardware combinations are verified.

## 2026-08-09 — Rebase before the next fork prerelease

**Context.** The local universal candidate predates the designated upstream
`v3.4.2` baseline.

**Decision.** Integrate fork-specific Sender work onto `v3.4.2`, verify it
again, and only then consider a new prerelease.

**Consequences.** `3.3.0-intel.2` remains a local historical candidate rather
than a current release baseline. Receiver modernization remains a separate,
future effort.
