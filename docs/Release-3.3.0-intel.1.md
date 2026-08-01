# TargetBridge Intel Sender 3.3.0-intel.1

First public preview of the independently packaged Intel Sender fork maintained
by AndyStuardo. The original TargetBridge Receiver is unchanged.

## Highlights

- Thin native `x86_64` Sender for Intel Macs on macOS 14 or later.
- Separate app name, icon, bundle identifier, preferences, logs and data.
- Thunderbolt Bridge interface and Receiver-address inference using the real
  `bridge*` address and netmask, without hardcoded subnets or network changes.
- Intel VideoToolbox hardware H.264 and HEVC selection with fallback telemetry.
- 4K HiDPI profiles prioritizing logical 2048 x 1152 and 2304 x 1296.
- Work 4K, Work 5K, Low Latency and Presentation quick profiles.
- Duplicate Desktop and Extended Desktop modes.
- Experimental RAW NV12 transport when the Receiver advertises support.
- Spanish UI with automatic language selection and English fallback.
- Menu-bar controls for sessions, Receivers, display modes, profiles and brightness.
- Codec-aware menu-bar indicator for HEVC, H.264, RAW and mixed sessions.
- Attached side panels for global and per-session settings.
- Live telemetry panel with FPS history, codec, configured bitrate and resolution.
- Optional launch at login with login-only automatic reconnection; manual app launches do not connect.
- Safe `uninstall.sh` limited to the Intel Sender variant.

## Validated hardware

- Sender: Intel iMac Retina 5K 27-inch (2020), macOS Sequoia 15.7.7.
- Receiver: Intel iMac Retina 4K 21.5-inch, macOS Monterey, unchanged upstream Receiver.
- Link: Thunderbolt Bridge, Sender 10.0.0.1 to Receiver 10.0.0.2 over `bridge0`.
- Confirmed Intel hardware encoders: H.264 GVA and HEVC AVE.

## Installation

1. Unzip `TargetBridge-Intel-Sender-3.3.0-intel.1-x86_64.zip`.
2. Move `TargetBridge Intel Sender.app` to `/Applications`.
3. Open it and grant Screen Recording when requested.
4. Keep the original TargetBridge Receiver installed on the Receiver Mac.

The preview uses an ad-hoc signature and is not notarized. If macOS preserves a
download quarantine and refuses to open it, inspect the downloaded file first,
then run `xattr -cr "/Applications/TargetBridge Intel Sender.app"`.

## Known limitations

- This preview has been tested on one end-to-end Intel iMac configuration.
- RAW NV12 needs compatible Receiver support and can approach 6.8 Gbit/s at 4K60.
- Changing virtual-display topology briefly stops and reconnects the session.
- Telemetry bitrate is currently the configured target, not measured TCP throughput.
- Some inherited advanced help text may still fall back to English.
- The app is not presented as an Apple Silicon Sender; use upstream TargetBridge there.

## Attribution

Based on the MIT-licensed TargetBridge project by swellweb and its open-source
community. Intel Sender fork developed by AndyStuardo. Original copyright,
license and community credits are preserved.
