# Documentation

This folder documents TargetBridge Intel Sender as it exists on the
`intel-sender` branch. Some pages started upstream and have been updated where
the Intel package changes installation, compatibility or user interface.

## Start here

- [Quick start — Español](QuickStart-ES.md)
- [Quick start — English](QuickStart-EN.md)
- [Features and controls](Features.md)
- [Hardware and Thunderbolt Bridge](Hardware.md)
- [Compatibility and planned tests](Compatibility.md)

## Verification and development

- [Intel Sender audit](Intel-Sender-Audit.md): compilation, isolation,
  VideoToolbox and real-link findings.
- [Testing](Testing.md): unit tests, release checks and a template for reporting
  new hardware results.
- [VideoToolbox evidence](evidence/videotoolbox/imac-2020-sequoia-15.7.7.json):
  machine-readable output from the validated Intel Sender.
- [Release process](Release-Process.md): versioning, ZIP/DMG creation, signing,
  notarization and GitHub prereleases.
- [Binary verification](verify-binaries.md): GitHub artifact attestations.
- [Automation](Automation.md), [Add-ons](Addons.md),
  [Translations](Translations.md) and [audio internals](audio.md).

## Upstream material

The original TargetBridge Receiver remains unchanged in this fork. Receiver
build instructions and protocol-level tests therefore remain useful. Statements
about Sender architecture, package names, download URLs or supported display
profiles should use this fork's pages above rather than assuming the upstream
Apple Silicon defaults.

Documentation may evolve with the fork. Preserve attribution and links to the
original project, but correct inherited text when leaving it unchanged would
misdescribe the Intel Sender.
