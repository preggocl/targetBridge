# Project state

Updated: 2026-08-13

Branch: `intel-sender`. The separate `legacy-sender` branch remains the
macOS 12.3+ compatibility line.

Implemented and verified:

- Isolated Intel Sender identity, preferences, logs, packaging and uninstall.
- Intel-oriented 4K HiDPI profiles and VideoToolbox diagnostics.
- Full HD profiles: 1920 × 1080 H.264 at 30 fps and 60 fps. The Full HD quick
  profile uses extended desktop at 30 fps for conservative legacy receivers.
- Read-only Thunderbolt Bridge and Ethernet interface selection.
- 84 x86_64 Sender tests passed; build `20260813201500` was installed locally
  and verified as x86_64 with the isolated bundle identifier.
- Presentation mirror and extended modes were verified against a Receiver
  Legacy 3.5.0 prototype on an iMac 2011 running Big Sur 11.7.10.

Open work: test Full HD 30/60 over the physical link, including sustained
streaming, reconnect and Receiver fullscreen behavior. Receiver Legacy
packaging is experimental and is not a published release.
