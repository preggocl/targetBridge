#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SENDER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SENDER_ROOT/.." && pwd)"
VERSION="${1:-3.3.0-intel-legacy.1}"
APP_NAME="TargetBridge Intel Sender Legacy"
APP_PATH="$REPO_ROOT/build-legacy/$APP_NAME.app"
DIST_DIR="$REPO_ROOT/dist/$VERSION"
ARCHIVE_BASE="TargetBridge-Intel-Sender-$VERSION-x86_64"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/targetbridge-intel-legacy-release.XXXXXX")"

cleanup() { rm -rf -- "$STAGING_DIR"; }
trap cleanup EXIT

TB_LEGACY_BUILD_NUMBER="${TB_LEGACY_BUILD_NUMBER:-$(date -u +%Y%m%d%H%M%S)}" \
  "$SCRIPT_DIR/build_legacy_sender_app.sh"

[[ -d "$APP_PATH" ]] || { echo "Missing app: $APP_PATH" >&2; exit 1; }
mkdir -p "$DIST_DIR"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$DIST_DIR/$ARCHIVE_BASE.zip"
ditto "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"
hdiutil create -volname "$APP_NAME $VERSION" -srcfolder "$STAGING_DIR" \
  -ov -format UDZO "$DIST_DIR/$ARCHIVE_BASE.dmg" >/dev/null

(
  cd "$DIST_DIR"
  shasum -a 256 "$ARCHIVE_BASE.zip" "$ARCHIVE_BASE.dmg" > SHA256SUMS.txt
)

echo "Release artifacts:"
echo "  $DIST_DIR/$ARCHIVE_BASE.zip"
echo "  $DIST_DIR/$ARCHIVE_BASE.dmg"
echo "  $DIST_DIR/SHA256SUMS.txt"
