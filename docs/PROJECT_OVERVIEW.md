# TargetBridge Intel Sender

TargetBridge Intel Sender is an independent Sender fork of
[TargetBridge](https://github.com/swellweb/targetBridge). It creates a virtual
macOS display, captures it and sends the resulting stream to a compatible
TargetBridge Receiver. The fork began as an Intel Mac compatibility effort and
is packaged as a universal macOS Sender (`x86_64` and `arm64`).

The project keeps a distinct application identity, bundle identifier,
preferences, support data, logs and uninstall path. It can therefore coexist
with the upstream TargetBridge application and Receiver installation. The
repository also contains an experimental legacy line with its own identity,
`com.targetbridge.intel-sender.legacy`, for Intel Macs on macOS 12.3+.

## Scope

The maintained scope is the separately packaged Sender and its supporting
documentation, tests and release tooling. The upstream Receiver source remains
unchanged in this fork. Network configuration is intentionally outside the
application's scope: the Sender reads available interfaces and binds the one
selected for a display, but does not alter network services, addresses, routes
or Wi-Fi state.

The project does not store Receiver login credentials or bypass macOS security
boundaries such as the Lock Screen or FileVault.

## Main capabilities

- Universal Sender builds for Intel and Apple Silicon Macs.
- Isolated `TargetBridge Intel Sender.app` packaging and safe uninstallation.
- Intel-oriented 4K workflow profiles, including 2048 x 1152 and 2304 x 1296
  logical HiDPI modes.
- VideoToolbox capability reporting for H.264 and HEVC, with runtime telemetry
  for codec selection, hardware state, fallback, FPS, bitrate and errors.
- Thunderbolt Bridge and experimental Network Link selection without automatic
  network changes.
- Optional experimental RAW NV12 transport when both endpoints support it.
- Sender UI improvements: localized controls, quick menu actions, telemetry,
  launch options and attached settings panels.

The legacy line is x86_64-only, uses a macOS 12.3 deployment target and hides
session-level system-audio capture where the native API is unavailable. The
Audio Relay add-on remains listed for future evaluation.

Several capabilities remain inherited from TargetBridge, including the shared
wire protocol, Receiver implementation, Work 5K / Low Latency / Presentation
profiles, duplicate and extended display modes, Cable Test, Audio Relay, Input
Dockstation and remote brightness. The fork documents its adaptations without
claiming those inherited capabilities as new work.

## Repository layout

| Area | Responsibility |
| --- | --- |
| `TargetBridge-Sender/` | Swift macOS Sender, unit tests, assets and build scripts. |
| `TargetBridge-Receiver/` | Unmodified upstream Receiver source and its C-based test tools. |
| `Shared/` | Shared protocol and localization resources used by the applications. |
| `docs/` | User guides, compatibility records, release material and project continuity documentation. |
| `build-intel/` | Local, generated Sender build output; not versioned source. |

## Related documentation

- [Features and controls](Features.md)
- [Compatibility matrix](Compatibility.md)
- [Testing guidance](Testing.md)
- [Intel Sender audit](Intel-Sender-Audit.md)
- [Release process](Release-Process.md)
- [Current operational state](PROJECT_STATE.md)
- [Architecture](ARCHITECTURE.md)
- [Roadmap](ROADMAP.md)
