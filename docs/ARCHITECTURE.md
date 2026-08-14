# Architecture

The Sender creates or mirrors a virtual display, captures it with
ScreenCaptureKit, encodes H.264 or HEVC through VideoToolbox (or experimental
RAW NV12), and sends one TCP stream over the selected interface. The Receiver
decodes and presents the stream using the shared protocol.

Thunderbolt Bridge, Ethernet and Network Link are alternative paths for one
connection; the application does not bond or stripe links. Full HD presets are
explicit H.264 paths for receivers without HEVC hardware decoding. The
existing Receiver remains a separate component and is not modified by the
Sender package.
