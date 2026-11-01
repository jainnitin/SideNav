#!/bin/sh
# usage: dmg.sh <path/to/SideNav.app> <out.dmg>
# Builds a drag-to-Applications installer window: background, arrow, icon layout.
set -e
cd "$(dirname "$0")"
APP="$1"; OUT="$2"; VOL="SideNav"
WORK=$(mktemp -d)
trap 'hdiutil detach "/Volumes/$VOL" -force >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT
hdiutil detach "/Volumes/$VOL" -force >/dev/null 2>&1 || true

swiftc -O dmg-background.swift -o "$WORK/bg" && "$WORK/bg" "$WORK/bg.png"
mkdir "$WORK/stage" "$WORK/stage/.background"
ditto "$APP" "$WORK/stage/SideNav.app"
cp "$WORK/bg.png" "$WORK/stage/.background/bg.png"

hdiutil create -srcfolder "$WORK/stage" -volname "$VOL" -fs HFS+ -format UDRW -ov "$WORK/rw.dmg" >/dev/null
hdiutil attach -readwrite -noverify -noautoopen "$WORK/rw.dmg" >/dev/null
ln -s /Applications "/Volumes/$VOL/Applications"

osascript <<OSA
tell application "Finder"
  tell disk "$VOL"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 740, 502}
    set opts to the icon view options of container window
    set arrangement of opts to not arranged
    set icon size of opts to 112
    set text size of opts to 13
    set background picture of opts to file ".background:bg.png"
    set position of item "SideNav.app" of container window to {140, 185}
    set position of item "Applications" of container window to {400, 185}
    update without registering applications
    delay 2
    close
  end tell
end tell
OSA
sync; sleep 1
hdiutil detach "/Volumes/$VOL" >/dev/null
mkdir -p "$(dirname "$OUT")"; rm -f "$OUT"
hdiutil convert "$WORK/rw.dmg" -format UDZO -o "$OUT" >/dev/null
echo "Created $OUT"
