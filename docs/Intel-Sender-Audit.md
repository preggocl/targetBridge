# TargetBridge Intel Sender audit

Date: 2026-07-31. Host: iMac Intel, macOS 15.7.7, Xcode 26.3 (17C529).

## Baseline audit

- Branch created before edits: `intel-sender`.
- Project: `TargetBridge-Sender/TargetBridge.xcodeproj`.
- Scheme: `TBDisplaySender`.
- Targets: `TBDisplaySender`, `TBDisplaySenderTests`.
- Minimal Debug build with `ARCHS=x86_64` succeeded.
- Release Intel variant build succeeded and produced a Mach-O `x86_64` executable.
- No source, framework or linked dependency proved exclusive to Apple Silicon.
- The private IOAVService declarations are DDC-related and did not prevent Intel compilation or linking.

Observed non-blocking warnings: legacy `CGDisplayStream` APIs deprecated on macOS 14+, Swift 6 concurrency/Sendable warnings, deprecated `String(cString:)`, and `actool`/CoreMedia private-symbol warnings on this macOS/Xcode combination.

## Isolation

The variant is `TargetBridge Intel Sender.app`, bundle ID `com.targetbridge.intel-sender`, URL scheme `targetbridge-intel`, defaults domain `com.targetbridge.intel-sender`, unified-log subsystem `com.targetbridge.intel-sender`, and Application Support directory `~/Library/Application Support/TargetBridge Intel Sender`.

The original Receiver target and all files below `TargetBridge-Receiver/` are unchanged.

## VideoToolbox results

The x86_64 probe created and prepared hardware-required sessions on the actual Intel sender. Full machine-readable output is in `docs/intel-videotoolbox-probe.json`.

| Resolution | FPS | Bitrate | Codec | Hardware | Encoder ID | Status | Fallback |
|---|---:|---:|---|---|---|---:|---|
| 2048x1152 | 60 | 32 Mbps | H.264 | yes | `com.apple.videotoolbox.videoencoder.h264.gva` | 0 | none |
| 2048x1152 | 60 | 32 Mbps | HEVC | yes | `com.apple.videotoolbox.videoencoder.hevc.ave` | 0 | none |
| 2304x1296 | 60 | 40 Mbps | H.264 | yes | `com.apple.videotoolbox.videoencoder.h264.gva` | 0 | none |
| 2304x1296 | 60 | 40 Mbps | HEVC | yes | `com.apple.videotoolbox.videoencoder.hevc.ave` | 0 | none |

The two prioritized 4K profiles prefer HEVC and fall back to H.264 when sender hardware or receiver decoding support is unavailable. A real end-to-end session subsequently confirmed HEVC at 4096 x 2304, 30 delivered FPS, over `bridge0` to the unchanged Monterey Receiver.

## 4K modes and low-latency experiment

- `Work 4K` selects extended desktop, render matching and logical 2048 x 1152 HiDPI.
- `4K HiDPI 2304` provides a larger logical 2304 x 1296 workspace while keeping the encoded stream at the Intel-safe 4096 x 2304 ceiling.
- The menu-bar icon exposes every discovered Receiver, duplicate/extended source and capture preset. Changes made during a live session perform a controlled stop, virtual-display rebuild and reconnect; CoreGraphics cannot change that topology without a brief interruption.
- `RAW NV12 (experimental)` bypasses H.264/HEVC only when the Receiver advertises support. At 4096 x 2304 x 60 it carries about 6.8 Gbit/s before framing overhead, so it may reduce codec latency but can increase copy pressure, dropped frames and instability.
- A second Thunderbolt cable is not used for one session. Each session creates one TCP connection bound to one local address/interface, and the compressed 4K profiles use only 80 Mbps nominal bitrate. Multi-path striping would require a new protocol at both ends and would not address capture, display-refresh or encode/decode delay.

## Attribution

This branch identifies itself as version `3.3.0-intel.1`. The About panel credits the original TargetBridge project and community, identifies AndyStuardo as developer of the Intel Sender fork, and preserves the original MIT copyright and attribution. The upstream Receiver remains unchanged.

## Receiver lock-screen boundary

The upstream Receiver is a normal GUI process in the logged-in user's session.
It contains no display-sleep assertion, so after it exits the Receiver Mac
follows its own screen-saver, display-sleep and password policies. The Intel
Sender only asserts `idleSystemSleepDisabled` while streaming and optionally
`idleDisplaySleepDisabled`; these assertions apply to the Sender Mac, not the
Receiver.

No credential-based unlock is implemented or recommended. The macOS Lock
Screen and FileVault login are security boundaries that a Receiver connection
must not bypass. A future Receiver fork may safely provide launch-at-login,
automatic listening/reconnection and an opt-in display-sleep assertion while
waiting or connected, without storing credentials or changing system security
settings.

## Thunderbolt Bridge

Read-only verification showed `10.0.0.2` routed through `bridge0`; `bridge0` was active at `10.0.0.1/24`. Three ICMP probes succeeded with 0% loss and 1.374 ms average RTT. No network settings or Wi-Fi state were changed.

This validates reachability and routing, not sustained end-to-end video. A real receiver session is still required to measure steady FPS, achieved bitrate, thermal behavior and visual stability.

## Test procedure

1. Build with `TargetBridge-Sender/scripts/build_intel_sender_app.sh`.
2. Copy `build-intel/TargetBridge Intel Sender.app` to `/Applications` if desired; do not replace the original app.
3. Start the unchanged TargetBridge Receiver on `10.0.0.2`.
4. In the Intel Sender choose Thunderbolt Bridge, local IP `10.0.0.1`, receiver `10.0.0.2`, then test `4K HiDPI 2048` before `4K HiDPI 2304`.
5. Inspect live logs with `log stream --predicate 'subsystem == "com.targetbridge.intel-sender"'` and record FPS, encoder, bitrate, resolution, interface and any VideoToolbox/network errors.
6. Repeat for at least 15 minutes per profile and note dropped frames, latency, thermals and reconnect behavior.
7. Uninstall only this variant with `./uninstall.sh` (or `./uninstall.sh --yes`).

## Viability

Compilation and hardware encoder availability are confirmed. Thunderbolt reachability is confirmed. The adaptation is viable for an Intel sender at the two requested logical resolutions. Final production confidence remains conditional on an end-to-end sustained session with the Monterey Receiver, because that cannot be inferred from encoder-session creation and ping alone.
