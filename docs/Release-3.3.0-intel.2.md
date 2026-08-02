# TargetBridge Intel Sender 3.3.0-intel.2 — universal prerelease

This prerelease changes the isolated TargetBridge Intel Sender package from a
thin `x86_64` build to a universal macOS application containing both `x86_64`
and `arm64` slices. The application name, bundle identifier
`com.targetbridge.intel-sender`, URL scheme and separate user data locations
remain unchanged, so it does not replace the original TargetBridge app or the
Receiver.

## Validated

- Universal Release bundle created on the Intel iMac with Xcode 26.3.
- `lipo` verified both `x86_64` and `arm64` executable slices.
- x86_64 unit suite: 83 tests passed.
- Native M1 test: app launch, virtual-display creation, Screen Recording,
  hardware HEVC AVE selection, first encoded frame and an established
  Thunderbolt Bridge stream to the unchanged Intel Receiver.
- ZIP, DMG, SHA-256 checksums and ad-hoc code signatures were verified locally.

## Distribution files

- `TargetBridge-Intel-Sender-3.3.0-intel.2-universal.zip`
- `TargetBridge-Intel-Sender-3.3.0-intel.2-universal.dmg`
- `SHA256SUMS.txt`

The package is ad-hoc signed, not Developer ID signed or notarized. Gatekeeper
may therefore require an explicit user approval on a Mac that has not run this
variant before.

## Attribution

This is an independent fork distribution based on the MIT-licensed
TargetBridge project by Marco Caciotti (`swellweb`) and contributors. It keeps
the original license and preserves the unchanged upstream Receiver. The fork
is maintained by AndyStuardo; its distinct packaging, 4K Intel workflow and
diagnostics remain separate from upstream work and from the focused upstream
build/CI pull requests.
