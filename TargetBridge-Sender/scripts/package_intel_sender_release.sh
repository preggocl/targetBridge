#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SENDER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SENDER_ROOT/.." && pwd)"
VERSION="${1:-3.3.0-intel.2}"
APP_NAME="TargetBridge Intel Sender"
APP_PATH="$REPO_ROOT/build-intel/$APP_NAME.app"
DIST_DIR="$REPO_ROOT/dist/$VERSION"
ARCHIVE_BASE="TargetBridge-Intel-Sender-$VERSION-universal"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/targetbridge-intel-release.XXXXXX")"

cleanup() {
  rm -rf -- "$STAGING_DIR"
}
trap cleanup EXIT

"$SCRIPT_DIR/build_intel_sender_app.sh"

EXECUTABLE="$APP_PATH/Contents/MacOS/$APP_NAME"
[[ -x "$EXECUTABLE" ]] || { echo "Missing executable: $EXECUTABLE" >&2; exit 1; }
for arch in x86_64 arm64; do
  /usr/bin/lipo "$EXECUTABLE" -verify_arch "$arch" || {
    echo "Release is missing $arch" >&2
    exit 1
  }
done
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Contents/Info.plist")" == "com.targetbridge.intel-sender" ]] || {
  echo "Unexpected bundle identifier" >&2
  exit 1
}
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

mkdir -p "$DIST_DIR"
ditto -c -k --sequesterRsrc --keepParent \
  "$APP_PATH" "$DIST_DIR/$ARCHIVE_BASE.zip"

ditto "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"
hdiutil create \
  -volname "$APP_NAME $VERSION" \
  -srcfolder "$STAGING_DIR" \
  -ov -format UDZO \
  "$DIST_DIR/$ARCHIVE_BASE.dmg" >/dev/null

(
  cd "$DIST_DIR"
  shasum -a 256 "$ARCHIVE_BASE.zip" "$ARCHIVE_BASE.dmg" > SHA256SUMS.txt
)

echo "Release artifacts:"
echo "  $DIST_DIR/$ARCHIVE_BASE.zip"
echo "  $DIST_DIR/$ARCHIVE_BASE.dmg"
echo "  $DIST_DIR/SHA256SUMS.txt"
echo "These universal artifacts are ad-hoc signed unless build_intel_sender_app.sh is replaced with a Developer ID signing/export step."
