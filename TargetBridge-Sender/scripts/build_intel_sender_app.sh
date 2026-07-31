#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SENDER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SENDER_ROOT/.." && pwd)"
DERIVED_DATA_DIR="${TMPDIR:-/tmp}/TargetBridgeIntelSender-DerivedData"
PRODUCT_NAME="TargetBridge Intel Sender"
DEST_DIR="$REPO_ROOT/build-intel"

cd "$SENDER_ROOT"
xcodebuild \
  -project TargetBridge.xcodeproj \
  -scheme TBDisplaySender \
  -configuration Release \
  -destination 'platform=macOS,arch=x86_64' \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  ARCHS=x86_64 \
  ONLY_ACTIVE_ARCH=YES \
  PRODUCT_NAME="$PRODUCT_NAME" \
  PRODUCT_BUNDLE_IDENTIFIER=com.targetbridge.intel-sender \
  INFOPLIST_FILE=TargetBridgeSupport/IntelSender-Info.plist \
  CODE_SIGNING_ALLOWED=NO \
  build

SOURCE_APP="$DERIVED_DATA_DIR/Build/Products/Release/$PRODUCT_NAME.app"
DEST_APP="$DEST_DIR/$PRODUCT_NAME.app"
mkdir -p "$DEST_DIR"
if [[ -e "$DEST_APP" ]]; then
  rm -rf -- "$DEST_APP"
fi
ditto "$SOURCE_APP" "$DEST_APP"
xattr -cr "$DEST_APP" || true
codesign --force --deep --sign - "$DEST_APP"

echo "Built: $DEST_APP"
file "$DEST_APP/Contents/MacOS/$PRODUCT_NAME"
codesign -dv "$DEST_APP" 2>&1
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DEST_APP/Contents/Info.plist"
