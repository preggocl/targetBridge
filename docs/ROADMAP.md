# Roadmap

## Next / committed

1. Publish and test the explicitly labelled `3.3.0-intel-legacy.1` branch
   candidate on the Monterey Intel iMac.
2. Integrate the isolated Sender work onto upstream TargetBridge `v3.4.2` in
   small, reviewable changes.
3. Re-run Sender unit tests, universal binary/package checks and representative
   Intel and Apple Silicon end-to-end tests after integration.
4. Prepare a clearly labelled universal prerelease only if those checks succeed; retain
   the original Receiver and network configuration boundaries.

## Planned

- Refresh the compatibility matrix with repeatable long-duration, reconnect
  and sleep/wake evidence for supported Sender/Receiver combinations.
- Improve release readiness with signing/notarization planning and repeatable
  artifact verification.
- Assess a separately packaged Receiver hybrid/legacy variant with explicit
  protocol compatibility, safe lifecycle behavior and a modest UI layer.
- Expand Receiver validation for older Intel Macs over practical Ethernet and
  Thunderbolt configurations, using conservative profiles where necessary.
- Evaluate whether Audio Relay can be supported on legacy macOS through an
  optional, explicitly documented audio path; do not make it a baseline
  dependency.

## Exploratory

- Receiver capability profiles that adapt resolution, codec and bitrate to
  hardware decode capability and transport measurements.
- Better session recovery after display sleep, disconnects and Receiver
  relaunches without weakening macOS login security.
- Broader receiver support for portable Macs and older Intel hardware, subject
  to real decode, rendering and transport measurements.
- Optional color metadata and presentation diagnostics, provided they can be
  added without breaking the existing protocol.

Items in this section are not release commitments. Each requires a scoped
design, compatibility review and measured validation before implementation.
