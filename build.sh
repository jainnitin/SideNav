#!/bin/sh
# Local build. Ad-hoc signed unless SIGN_ID (and SIGN_FLAGS) are set, as release.sh does.
set -e
cd "$(dirname "$0")"
ID="${SIGN_ID:--}"
APP=SideNav.app
APPEX=$APP/Contents/PlugIns/SideNavExtension.appex
rm -rf $APP
mkdir -p $APP/Contents/MacOS $APP/Contents/Resources $APPEX/Contents/MacOS $APPEX/Contents/Resources
swiftc -O host.swift -o $APP/Contents/MacOS/SideNav
swiftc -O -parse-as-library -application-extension -framework SafariServices \
  handler.swift -Xlinker -e -Xlinker _NSExtensionMain -o $APPEX/Contents/MacOS/SideNavExtension
cp host.plist $APP/Contents/Info.plist
cp AppIcon.icns $APP/Contents/Resources/
cp ext.plist $APPEX/Contents/Info.plist
cp ext/manifest.json ext/content.js ext/icon-*.png $APPEX/Contents/Resources/
codesign --force $SIGN_FLAGS --entitlements ext.entitlements --sign "$ID" $APPEX
codesign --force $SIGN_FLAGS --entitlements host.entitlements --sign "$ID" $APP
codesign --verify --deep --strict $APP
# Keep Safari from seeing this copy as a duplicate of the installed extension.
pluginkit -r $APPEX 2>/dev/null || true
