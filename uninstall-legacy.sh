#!/bin/bash
set -euo pipefail

BUNDLE_ID="com.targetbridge.intel-sender.legacy"
APP_NAME="TargetBridge Intel Sender Legacy.app"
SUPPORT_NAME="TargetBridge Intel Sender Legacy"
USER_LIBRARY="$HOME/Library"

targets=(
  "/Applications/$APP_NAME"
  "$HOME/Applications/$APP_NAME"
  "$USER_LIBRARY/Preferences/$BUNDLE_ID.plist"
  "$USER_LIBRARY/Caches/$BUNDLE_ID"
  "$USER_LIBRARY/Logs/$SUPPORT_NAME"
  "$USER_LIBRARY/Application Support/$SUPPORT_NAME"
  "$USER_LIBRARY/Saved Application State/$BUNDLE_ID.savedState"
  "$USER_LIBRARY/HTTPStorages/$BUNDLE_ID"
  "$USER_LIBRARY/WebKit/$BUNDLE_ID"
  "$USER_LIBRARY/LaunchAgents/$BUNDLE_ID.plist"
)

if [[ "${1:-}" != "--yes" ]]; then
  echo "This removes only TargetBridge Intel Sender Legacy data:"
  printf '  %s\n' "${targets[@]}"
  echo "TargetBridge Receiver, TargetBridge Intel Sender, AirDisplay, Wi-Fi and Thunderbolt settings are not touched."
  read -r -p "Continue? [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]] || exit 0
fi

osascript -e 'tell application "TargetBridge Intel Sender Legacy" to quit' 2>/dev/null || true
/bin/launchctl bootout "gui/$(id -u)/$BUNDLE_ID" 2>/dev/null || true
for target in "${targets[@]}"; do
  if [[ -e "$target" || -L "$target" ]]; then
    rm -rf -- "$target"
    echo "Removed $target"
  fi
done

/usr/bin/killall cfprefsd 2>/dev/null || true
echo "TargetBridge Intel Sender Legacy uninstall complete."
