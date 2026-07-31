#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SENDER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT="${1:-$SENDER_ROOT/../docs/intel-videotoolbox-probe.json}"
PROBE_BINARY="${TMPDIR:-/tmp}/targetbridge-videotoolbox-probe"

xcrun swiftc -target x86_64-apple-macos14.0 \
  -framework Foundation -framework CoreMedia -framework VideoToolbox \
  "$SENDER_ROOT/tools/videotoolbox_probe.swift" -o "$PROBE_BINARY"
file "$PROBE_BINARY"
"$PROBE_BINARY" | tee "$OUTPUT"
