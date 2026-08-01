# TargetBridge Intel Sender 3.3.0-intel.1

First public preview of the independently packaged Intel Sender fork maintained
by AndyStuardo. Its goal is to make the TargetBridge Sender usable and
diagnosable on Intel Macs without replacing the original application or
repackaging the Receiver.

## Intel fork additions and adaptations

- Thin native `x86_64` Sender for Intel Macs on macOS 14 or later.
- Separate app name, icon, bundle identifier, preferences, logs and data.
- Petroleum-blue application icon with a small `x86` compatibility badge; the
  functional menu-bar icon remains unchanged.
- Thunderbolt Bridge interface and Receiver-address inference using the real
  `bridge*` address and netmask, without hardcoded subnets or network changes.
- Intel VideoToolbox hardware H.264 and HEVC selection with fallback telemetry.
- 4K HiDPI profiles prioritizing logical 2048 x 1152 and 2304 x 1296.
- `Work 4K` quick profile for the validated 21.5-inch 4K iMac workflow.
- Experimental RAW NV12 transport when the Receiver advertises support.
- Spanish UI with automatic language selection and English fallback.
- Menu-bar controls for displays, Receivers, display modes, profiles and brightness.
- Codec-aware menu-bar indicator for HEVC, H.264, RAW and mixed displays.
- Attached side panels for global and per-session settings.
- Live telemetry panel with FPS history, codec, configured bitrate and resolution.
- Optional launch at login with login-only automatic reconnection; manual app launches do not connect.
- User-facing `Display/Pantalla` terminology and a larger **Connect display**
  action with a play symbol; internal protocol/session identifiers remain
  unchanged for compatibility.
- Safe `uninstall.sh` limited to the Intel Sender variant.
- Fork-specific README, Spanish and English quick starts, compatibility matrix,
  reproducible evidence layout, hardware guide and release procedure.

## Retained TargetBridge capabilities

This preview also retains these upstream TargetBridge capabilities. They are
not claimed as new work by the Intel fork:

- Cable Test throughput measurement and guided connection diagnostics.
- `Work 5K`, `Low Latency` and `Presentation` quick profiles.
- Duplicate and Extended Desktop streaming, Thunderbolt Bridge transport and
  experimental Network Link.
- Audio Relay, Input Dockstation, remote brightness, multi-Receiver sessions
  and the shared Sender/Receiver protocol.

The fork adapts UI presentation and documentation around these capabilities
where necessary for Intel packaging and 4K workflows.

## Validated hardware

- Sender: Intel iMac Retina 5K 27-inch (2020), macOS Sequoia 15.7.7.
- Receiver: Intel iMac Retina 4K 21.5-inch, macOS Monterey, unchanged upstream Receiver.
- Link: Thunderbolt Bridge, Sender 10.0.0.1 to Receiver 10.0.0.2 over `bridge0`.
- Confirmed Intel hardware encoders: H.264 GVA and HEVC AVE.
- Sender unit suite: 82 tests passed on the validated Intel host.

## Installation

1. Unzip `TargetBridge-Intel-Sender-3.3.0-intel.1-x86_64.zip`.
2. Move `TargetBridge Intel Sender.app` to `/Applications`.
3. Open it and grant Screen Recording when requested.
4. Keep the original TargetBridge Receiver installed on the Receiver Mac.

The prerelease also provides a DMG for drag-to-Applications installation and a
`SHA256SUMS.txt` file. GitHub provides source ZIP and TAR.GZ archives
automatically; those source archives are not installable applications.

The preview uses an ad-hoc signature and is not notarized. If macOS preserves a
download quarantine and refuses to open it, inspect the downloaded file first,
then run `xattr -cr "/Applications/TargetBridge Intel Sender.app"`.

## Known limitations

- This preview has been tested on one end-to-end Intel iMac configuration.
- An Intel Sender to Apple Silicon Receiver is protocol-compatible in design
  but has not yet completed a real two-Mac test.
- Running this thin x86_64 Sender on Apple Silicon through Rosetta 2 is planned,
  not currently claimed as supported or native.
- RAW NV12 needs compatible Receiver support and can approach 6.8 Gbit/s at 4K60.
- Changing virtual-display topology briefly stops and reconnects the session.
- Telemetry bitrate is currently the configured target, not measured TCP throughput.
- Some inherited advanced help text may still fall back to English.
- The app is not presented as an Apple Silicon Sender; use upstream TargetBridge there.

## Attribution

Based on the MIT-licensed TargetBridge project by swellweb and its open-source
community. The retained TargetBridge features above remain attributed to their
upstream contributors. Intel Sender-specific additions and adaptations are
developed by AndyStuardo. Original copyright, license and community credits are
preserved.
