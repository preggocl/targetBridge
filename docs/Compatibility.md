# Compatibility and test matrix

TargetBridge has two independent roles. The Sender captures and encodes a
display; the Receiver decodes and presents it. Either role can run on Intel or
Apple Silicon when a compatible build exists, so the connection is not tied to
one physical direction.

## Current matrix

| Sender | Receiver | Status | Notes |
|---|---|---|---|
| Intel iMac 27-inch 5K 2020, Sequoia 15.7.7 | Intel iMac 21.5-inch 4K, Monterey | Verified | Thunderbolt Bridge, HEVC and H.264 hardware encoding; 4096 x 2304 HEVC observed at 30 delivered FPS |
| MacBook Air M1, Sequoia 15.7.7 | Intel iMac 21.5-inch 4K, Monterey | Verified | Native `arm64` Sender from the universal package; Thunderbolt Bridge `10.0.0.3` to `10.0.0.2`; hardware HEVC AVE, 4096 x 2304, no codec fallback |
| Intel Mac with this fork | Apple Silicon Mac with arm64 Receiver | Expected, unverified | The universal Sender is native on Intel; requires an arm64 Receiver package and an end-to-end test |
| Apple Silicon Mac with this fork | Intel iMac Receiver | Verified | Native `arm64`; do not use Rosetta for this supported configuration |

“Expected” means that no protocol or code-path restriction has been identified.
It is not a substitute for a real capture, encode, network, decode and display
test.

## Remaining Apple Silicon tests

The MacBook Air M1 was verified as Sender against the Intel 4K Receiver. It
should still be tested against:

1. iMac 21.5-inch 4K 2019 Receiver;
2. iMac 27-inch 5K 2020 Receiver.

For each Receiver, record:

- confirm the universal binary runs native `arm64`, without Rosetta 2;
- whether the Intel-specific bundle remains isolated from upstream TargetBridge;
- Receiver discovery on Wi-Fi and Thunderbolt Bridge;
- duplicate and extended display creation;
- 2048 x 1152, 2304 x 1296 and appropriate 5K profiles;
- selected codec, encoder identifier and hardware-acceleration flag;
- configured and observed FPS, bitrate, resolution and first-frame time;
- input latency, dropped frames, thermal behavior and reconnect results;
- Screen Recording, audio and input permission behavior.

The universal architecture claim is backed by a local two-slice build and a
native M1 launch, capture, hardware encode and Thunderbolt stream. Each new
Sender/Receiver hardware pair still needs its own end-to-end evidence.

## Reverse direction

An Intel iMac Sender can connect to an Apple Silicon Receiver. The destination
will show the stream in the Receiver application, normally fullscreen; this is
software display presentation, not Apple's former hardware Target Display Mode.
No credentials or automatic unlock are involved.

The practical limitation is Receiver packaging: this fork currently distributes
only its isolated universal Sender and deliberately does not republish Receiver
applications.
Obtain the appropriate arm64 Receiver from the original project, then validate
the pair before relying on it.
