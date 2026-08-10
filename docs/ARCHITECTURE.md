# Architecture

## Components

| Component | Responsibility |
| --- | --- |
| Sender app | Manages display configuration, virtual displays, capture, encoding, connection lifecycle, menu controls and telemetry. |
| Shared protocol | Defines handshake, control, media, audio and input messages exchanged between Sender and Receiver. |
| Receiver | Accepts the stream, decodes it and presents it. The existing Receiver implementation is retained unchanged in this fork. |
| Build and packaging scripts | Build the separately identified Sender, archive local outputs and produce ZIP/DMG release candidates. |
| Diagnostics and evidence | Record capability probes and repeatable test results without embedding private machine configuration. |

## Stream path

```text
Sender configuration
  -> virtual display and capture
  -> VideoToolbox H.264 or HEVC encoding
     (or optional RAW NV12)
  -> one TCP stream bound to the selected interface
  -> Receiver protocol/parser
  -> decoder and renderer
  -> Receiver display
```

The Sender chooses one local interface per display connection. Thunderbolt
Bridge, Ethernet and other Network Link paths are transports for that single
connection; the application does not bond or stripe multiple physical links.

## Encoding and presentation

The stable path uses VideoToolbox H.264 or HEVC. The Sender records selected
codec, encoder identity, hardware requirement, fallback, dimensions, target
bitrate, frame rate and relevant errors. RAW NV12 bypasses codec compression
only when the Receiver advertises compatible support; it is experimental
because it trades codec delay for much greater transport and memory pressure.

The existing Receiver is implemented primarily in C with a small Objective-C
bridge. It uses the shared protocol and native macOS media/display frameworks
alongside its decoding and rendering dependencies. Its implementation is not a
dependency of the isolated Sender application identity.

## Data and isolation

The Intel Sender variant owns its preferences, Application Support data and
logs. Its uninstall script targets only these variant-specific locations.
Receiver data, upstream TargetBridge data and macOS network configuration are
not part of the Sender's persistence or cleanup scope.

## Build boundaries

The Sender Xcode project and test target are under `TargetBridge-Sender/`.
The release script produces a universal application and local artifacts in
`build-intel/`. Generated build output is not source of truth; reproducibility
comes from versioned source, scripts and the verification procedure in
[Testing](Testing.md) and [Release process](Release-Process.md).

The `legacy-sender` branch adds a separately packaged x86_64 application with
bundle identifier `com.targetbridge.intel-sender.legacy`, its own LaunchAgent,
support directory and logs. Its build script overrides the deployment target
to macOS 12.3 while leaving the universal line unchanged. On macOS 12 the
session-level audio control is unavailable; the UI gates that control while
the Audio Relay add-on catalogue remains intact.
