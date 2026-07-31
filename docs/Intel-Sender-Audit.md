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

The two new prioritized profiles use H.264 for conservative Monterey receiver compatibility. For adaptive presets, HEVC is selected only when sender hardware and receiver decoding support are both reported; otherwise the recorded fallback is H.264.

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
