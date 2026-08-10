# TargetBridge Intel Sender 3.3.0-intel-legacy.1

Experimental legacy Sender compatibility line.

## Scope

This prerelease validates the Sender build path on Intel Macs running macOS
12.3 or later. It is intended for controlled testing with the original
TargetBridge Receiver. The Receiver source and application are unchanged.

The branch retains the Intel fork's 4K profiles, Thunderbolt/Ethernet transport
selection and display streaming path. It is x86_64-only and is separate from
the universal `3.3.0-intel.2` candidate.

## Audio behavior

The session-level “Stream audio” control is not shown on macOS 12 because the
native ScreenCaptureKit system-audio capture API is unavailable. The Audio
Relay add-on remains visible in Add-ons for future investigation and has not
been removed from the project.

## Evidence

- Xcode 26.3 (17C529) Debug build completed for `x86_64`.
- Deployment target: macOS 12.3.
- Real Intel iMac 2017 running macOS Monterey 12.7.6 accepted the isolated
  probe app.
- A direct virtual-display probe created a display on Monterey.
- The Sender and unchanged Receiver established TCP on port 54321 over the
  tested Ethernet link.

## Limitations

This is an ad-hoc signed development prerelease, not notarized. A complete
long-duration stream, sleep/wake and reconnect matrix on the physical Monterey
pair remains pending. System audio is not supported in this line.

Install the original Receiver separately. Do not replace an existing Receiver
installation or change macOS network configuration to use this branch.
