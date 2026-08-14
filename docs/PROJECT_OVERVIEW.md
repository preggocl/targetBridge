# Project overview

TargetBridge Intel Sender is a separately identified macOS Sender fork for
Intel-focused testing while retaining the upstream Sender/Receiver protocol.
The existing Receiver sources and installations are outside this application's
scope. Existing user-facing documentation is indexed in [docs/README.md](README.md).

The Sender is a Swift/AppKit/SwiftUI application using ScreenCaptureKit,
VideoToolbox and Network. It supports x86_64 builds and a universal package
where the current build configuration permits it. It selects one interface per
connection and does not change network settings.
