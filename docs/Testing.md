# Testing TargetBridge Intel Sender

The unit and parser suites run without a Thunderbolt cable or second Mac. Real
display quality, latency, VideoToolbox behavior and Receiver compatibility still
require two-machine tests. Keep those two kinds of evidence separate.

## 1. Sender unit tests (Swift)

Covers the wire protocol (framing, corrupt-length rejection, unknown-type
skipping, input-event encoder parity with `JSONDecoder`), the discovered-
receiver model (which IP is dialed per transport), connection diagnostics
(link-local interface scoping, failure-detail composition), and the
automation parsers behind `targetbridge-intel://` URLs and `--connect` launch
arguments.

```bash
cd TargetBridge-Sender
xcodebuild test \
  -project TargetBridge.xcodeproj \
  -scheme TBDisplaySender \
  -configuration Debug \
  -destination 'platform=macOS,arch=x86_64' \
  ARCHS=x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO
```

Test sources live in `TargetBridge-Sender/TBDisplaySenderTests/`.

The prerelease candidate completed 82 Sender tests with no failures on the
validated Intel iMac. A passing suite does not replace the real Receiver test.

## 2. Intel release package

Build the same separately identified application users will install:

```bash
TargetBridge-Sender/scripts/build_intel_sender_app.sh
file "build-intel/TargetBridge Intel Sender.app/Contents/MacOS/TargetBridge Intel Sender"
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' \
  "build-intel/TargetBridge Intel Sender.app/Contents/Info.plist"
codesign --verify --deep --strict --verbose=2 \
  "build-intel/TargetBridge Intel Sender.app"
```

Expected architecture is only `x86_64`; expected identifier is
`com.targetbridge.intel-sender`. The local build uses an ad-hoc signature for
repeatable testing. That is not Developer ID signing or notarization.

## 3. Receiver parser tests (C)

Unit tests for the streaming packet parser in `net.c` — fragmented and
contiguous feeds, the NUL-sentinel guarantee, corrupt/oversized length
rejection, and multi-megabyte payloads fed in socket-sized chunks.
Pure POSIX: needs **no ffmpeg, SDL, or pkgconf**.

```bash
cd TargetBridge-Receiver/TBReceiverC
make test
```

Test sources live in `TargetBridge-Receiver/TBReceiverC/tests/`.

## 4. Mock sender (protocol-level fault injection)

`TargetBridge-Receiver/TBReceiverC/tests/mock_sender.py` (stdlib-only
Python 3) speaks the full wire protocol against a running receiver:

| Mode        | What it exercises                                              |
|-------------|----------------------------------------------------------------|
| `handshake` | HELLO / heartbeat / TEARDOWN lifecycle                          |
| `stream`    | PARAM_SETS + AVCC H.264 frames (generated via the ffmpeg CLI)   |
| `hang`      | idle watchdog: silent sender is reaped after ~10s               |
| `badlen`    | parser rejects a corrupt `0xFFFFFFFF` length and disconnects    |
| `drop`      | abrupt mid-packet disconnect returns receiver to waiting        |

```bash
# terminal 1
cd TargetBridge-Receiver/TBReceiverC && make && ./tbreceiver --windowed

# terminal 2
python3 TargetBridge-Receiver/TBReceiverC/tests/mock_sender.py --mode stream --duration 5
```

## 5. Loopback smoke test (one command)

Builds the receiver, launches it windowed, and drives all mock-sender
phases with pass/fail assertions on the receiver's log:

```bash
TargetBridge-Receiver/scripts/loopback_smoke.sh            # full run
TargetBridge-Receiver/scripts/loopback_smoke.sh --no-stream  # skip the H.264 phase
```

Needs a GUI session (an SDL window opens briefly) and the receiver build
deps (`brew install ffmpeg sdl2 pkgconf`), so it is a local dev tool rather
than a CI job.

## 6. VideoToolbox capability probe

Run the probe on the Sender hardware being reported:

```bash
TargetBridge-Sender/scripts/probe_videotoolbox_intel.sh /path/to/result.json
```

The output proves whether VideoToolbox can create and prepare a
hardware-required session for each requested codec and size. It does not prove
delivered FPS, decoder compatibility or visual quality. Store curated evidence
under `docs/evidence/videotoolbox/` with a descriptive hardware and OS filename;
do not commit serial numbers, usernames, private IP inventories or credentials.

## 7. Real sender and receiver on one Mac (no cable)

The receiver binds `0.0.0.0:54321` and accepts any peer, so an Apple
Silicon Mac can stream to a receiver running on itself over the LAN
interface (the sender refuses `127.0.0.1`, so use the machine's own LAN IP
for both ends):

```bash
open "build-intel/TargetBridge Intel Sender.app"
./tbreceiver --windowed       # receiver on the same Mac
```

This exercises the true capture → encode → decode → render path minus the
Thunderbolt link itself.

## 8. Two-Mac acceptance test

For each Receiver and profile, record at least:

- Sender and Receiver model, architecture and macOS version;
- app version/commit and whether Rosetta 2 is involved;
- cable type, selected interface and route;
- Receiver address selected by discovery or entered manually;
- duplicate or extended mode and logical HiDPI size;
- encoded resolution, codec, encoder ID, hardware flag and fallback;
- target bitrate, delivered FPS, first-frame time and errors;
- cursor/input latency observations, dropped frames and thermals;
- reconnect, sleep/wake and permission behavior;
- test duration.

Start with 2048 x 1152, continue to 2304 x 1296, then test 5K or RAW only when
the stable profiles work. A useful daily-work result should run for at least 15
minutes; a release-confidence run should be longer and include normal desktop
activity rather than a static image.

## Debugging a live connection

The sender logs its connection lifecycle (dial target, interface, waiting/
failed states, timeouts) to unified logging:

```bash
log stream --predicate 'subsystem == "com.targetbridge.intel-sender"'
```

The receiver logs to stderr; under the LaunchAgent that lands in
`~/Library/Logs/TargetBridgeReceiver.launchd.err.log`.

## Experimental 5K at 60 FPS

`native5k60Experimental` is an opt-in HEVC profile for testing recent Apple
Silicon encoders at 5120 x 2880 and 60 FPS. It does not alter the stable 5K
profile, which remains at 48 FPS and is the recommended choice for daily work.

Real-world M4 testing has reached 56-57 FPS but also showed temporary drops
under mixed workloads and added heat when Input Dockstation is active. Treat
this profile as a benchmark and feedback tool, not a guaranteed 60 FPS mode.

Use it only for a test session, either from the Sender's stream-profile picker
or with the automation alias:

```bash
targetbridge connect --receiver <receiver-ip> --mode extended --preset 5k60
```

After at least one minute of normal desktop use, note the Sender FPS shown in
the display card, whether input remains responsive, and any capture or decoder
errors. For a two-Receiver experiment, start one display per Receiver and record
FPS separately. Include the complete acceptance-test fields above.
