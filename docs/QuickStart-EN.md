# TargetBridge Intel Sender quick start

This guide uses the Intel Sender from this fork and the unchanged TargetBridge
Receiver from the original project.

## Before you start

- Sender: Intel Mac running macOS 14 or later.
- Receiver: a Mac capable of running the appropriate TargetBridge Receiver.
- A real Thunderbolt cable and an active Thunderbolt Bridge service on both
  Macs. A USB-C charging or DisplayPort-only cable is not sufficient.

The app does not configure the network for you and does not disable Wi-Fi.

## Install

1. Install `TargetBridge Receiver.app` on the destination Mac.
2. Install `TargetBridge Intel Sender.app` on the Intel Sender Mac.
3. Keep the original and Intel applications separate; their bundle identifiers
   and data are independent.
4. Open the Receiver first and leave it on its waiting screen.
5. Open the Intel Sender and grant Screen Recording when macOS asks. Quit and
   reopen the app if macOS requires it after granting permission.

## Connect a display

1. Confirm that the Sender lists a Thunderbolt Bridge address. In the validated
   setup this is `bridge0 · 10.0.0.1`.
2. Click **Add display** if no display card exists.
3. Open **Display settings** for that card.
4. Choose **Thunderbolt Bridge** and its local interface address.
5. Select the discovered Receiver. If Bonjour only shows its Wi-Fi address,
   enter the Receiver's Thunderbolt address manually; the validated Receiver is
   `10.0.0.2`.
6. Choose **Extended Desktop** or **Duplicate Desktop**.
7. Start with **Work 4K** for a 4K iMac, then click **Connect display**.

When the first frame arrives, the Receiver switches to the stream. For an
extended desktop, arrange the virtual display under **System Settings →
Displays → Arrange** on the Sender.

## Recommended 4K profiles

- `Work 4K`: logical 2048 x 1152 HiDPI. This is the first profile to try.
- `4K HiDPI 2304`: logical 2304 x 1296 HiDPI. It provides more workspace while
  remaining within the validated Intel stream ceiling.
- `Low Latency`: favors motion and responsiveness over maximum sharpness.
- `Presentation`: favors a simple mirrored presentation workflow.

The logical size shown by macOS and the encoded pixel size are not the same.
For example, a logical 2048 x 1152 HiDPI desktop can be encoded as a
4096 x 2304 stream.

## Codecs

Leave codec selection automatic for first use. On the validated Intel iMac,
hardware H.264 and HEVC are available. HEVC generally gives better quality at a
given bitrate; H.264 is the compatibility fallback.

RAW NV12 bypasses video compression and may remove some codec delay, but it can
approach 6.8 Gbit/s at 4096 x 2304 and 60 FPS before protocol overhead. Enable
it only as an experiment when the Receiver advertises RAW support.

## Daily controls

The menu-bar item exposes the active displays, Receiver selection, display
mode, profiles and brightness. Changing display topology during a live stream
causes a controlled stop and reconnect because macOS must rebuild the virtual
display.

**Launch at login** starts the application with the user session. The separate
automatic-connect option reconnects the saved display only when launched as a
login item; opening the application manually does not auto-connect.

## Troubleshooting

- **Connect display is disabled:** choose both a local interface and Receiver
  address.
- **Permission prompt repeats:** verify the exact `TargetBridge Intel Sender`
  entry under Privacy & Security, then fully quit and reopen it.
- **Receiver found only on Wi-Fi:** select or enter its Thunderbolt address.
- **Everything looks too large:** choose the matching 2048 x 1152 or
  2304 x 1296 logical profile and allow the controlled reconnect.
- **No first frame:** run the guided configuration check and inspect logs with:

```bash
log stream --predicate 'subsystem == "com.targetbridge.intel-sender"'
```

To remove only this fork, run `./uninstall.sh` from the repository. Review the
script first; it does not remove the Receiver or network configuration.
