# Compatibility and test matrix

TargetBridge has two independent roles. The Sender captures and encodes a
display; the Receiver decodes and presents it. Either role can run on Intel or
Apple Silicon when a compatible build exists, so the connection is not tied to
one physical direction.

## Current matrix

| Sender | Receiver | Status | Notes |
|---|---|---|---|
| Intel iMac 27-inch 5K 2020, Sequoia 15.7.7 | Intel iMac 21.5-inch 4K, Monterey | Verified | Thunderbolt Bridge, HEVC and H.264 hardware encoding; 4096 x 2304 HEVC observed at 30 delivered FPS |
| Intel Mac with this fork | Apple Silicon Mac with arm64 Receiver | Expected, unverified | The protocol is shared and architecture-neutral; requires an arm64 Receiver package |
| Apple Silicon Mac with upstream Sender | Intel iMac Receiver | Upstream workflow | Use the upstream arm64 Sender rather than assuming this fork is native arm64 |
| Apple Silicon Mac running this `x86_64` Sender through Rosetta 2 | Intel Receiver | Planned | Launch, virtual-display creation, ScreenCaptureKit and VideoToolbox behavior must all be checked |

“Expected” means that no protocol or code-path restriction has been identified.
It is not a substitute for a real capture, encode, network, decode and display
test.

## Planned Apple Silicon tests

The next test host is a MacBook Air M1. It will be tested against:

1. iMac 21.5-inch 4K 2019 Receiver;
2. iMac 27-inch 5K 2020 Receiver.

For each Receiver, record:

- whether Rosetta 2 is required and whether the app launches;
- whether the Intel-specific bundle remains isolated from upstream TargetBridge;
- Receiver discovery on Wi-Fi and Thunderbolt Bridge;
- duplicate and extended display creation;
- 2048 x 1152, 2304 x 1296 and appropriate 5K profiles;
- selected codec, encoder identifier and hardware-acceleration flag;
- configured and observed FPS, bitrate, resolution and first-frame time;
- input latency, dropped frames, thermal behavior and reconnect results;
- Screen Recording, audio and input permission behavior.

If those tests succeed, the result should initially be documented as
“x86_64 under Rosetta 2”. A native or universal Apple Silicon claim requires an
arm64 build and a separate native test.

## Reverse direction

An Intel iMac Sender can connect to an Apple Silicon Receiver. The destination
will show the stream in the Receiver application, normally fullscreen; this is
software display presentation, not Apple's former hardware Target Display Mode.
No credentials or automatic unlock are involved.

The practical limitation is packaging: this fork currently distributes only
the Intel Sender and deliberately does not republish Receiver applications.
Obtain the appropriate arm64 Receiver from the original project, then validate
the pair before relying on it.
