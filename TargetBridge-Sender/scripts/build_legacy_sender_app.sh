#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SENDER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SENDER_ROOT/.." && pwd)"
DERIVED_DATA_DIR="${REPO_ROOT}/build-legacy/DerivedData-release"
PRODUCT_NAME="TargetBridge Intel Sender Legacy"
DEST_DIR="${REPO_ROOT}/build-legacy"
DEST_APP="${DEST_DIR}/${PRODUCT_NAME}.app"
BUILD_NUMBER="${TB_LEGACY_BUILD_NUMBER:-$(date -u +%Y%m%d%H%M%S)}"

cd "$SENDER_ROOT"
xcodebuild \
  -project TargetBridge.xcodeproj \
  -scheme TBDisplaySender \
  -configuration Release \
  -destination 'platform=macOS,arch=x86_64' \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  ARCHS=x86_64 \
  ONLY_ACTIVE_ARCH=YES \
  MACOSX_DEPLOYMENT_TARGET=12.3 \
  PRODUCT_NAME="$PRODUCT_NAME" \
  PRODUCT_BUNDLE_IDENTIFIER=com.targetbridge.intel-sender.legacy \
  MARKETING_VERSION=3.3.0-intel-legacy.1 \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
  INFOPLIST_FILE=TargetBridgeSupport/LegacySender-Info.plist \
  CODE_SIGNING_ALLOWED=NO \
  build

SOURCE_APP="$DERIVED_DATA_DIR/Build/Products/Release/${PRODUCT_NAME}.app"
mkdir -p "$DEST_DIR"
if [[ -e "$DEST_APP" ]]; then
  previous_app="$DEST_DIR/${PRODUCT_NAME}.previous.app"
  if [[ -e "$previous_app" ]]; then
    previous_app="$DEST_DIR/${PRODUCT_NAME}.previous.$BUILD_NUMBER.app"
  fi
  mv "$DEST_APP" "$previous_app"
fi
ditto "$SOURCE_APP" "$DEST_APP"
xattr -cr "$DEST_APP" || true
codesign --force --deep --sign - \
  --requirements '=designated => identifier "com.targetbridge.intel-sender.legacy"' \
  "$DEST_APP"

EXECUTABLE="$DEST_APP/Contents/MacOS/$PRODUCT_NAME"
file "$EXECUTABLE"
/usr/bin/lipo "$EXECUTABLE" -verify_arch x86_64
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DEST_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$DEST_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$DEST_APP/Contents/Info.plist"
codesign --verify --deep --strict --verbose=2 "$DEST_APP"
echo "Built: $DEST_APP"
