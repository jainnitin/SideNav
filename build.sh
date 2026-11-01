#!/bin/sh
set -e
SIGN_FLAGS="${SIGN_FLAGS:-}"
cd "$(dirname "$0")"
ID="${SIGN_ID:--}"
APP=SideNav.app
APPEX=$APP/Contents/PlugIns/SideNavExtension.appex
rm -rf $APP
mkdir -p $APP/Contents/MacOS $APPEX/Contents/MacOS $APPEX/Contents/Resources
swiftc -O host.swift -o $APP/Contents/MacOS/SideNav
swiftc -O -parse-as-library -application-extension -framework SafariServices \
  handler.swift -Xlinker -e -Xlinker _NSExtensionMain -o $APPEX/Contents/MacOS/SideNavExtension
cp host.plist $APP/Contents/Info.plist
mkdir -p $APP/Contents/Resources && cp AppIcon.icns $APP/Contents/Resources/
cp ext.plist $APPEX/Contents/Info.plist
cp ext/manifest.json ext/content.js ext/icon-*.png $APPEX/Contents/Resources/
codesign --force ${SIGN_FLAGS} --entitlements ext.entitlements --sign "$ID" $APPEX
codesign --force ${SIGN_FLAGS} --entitlements host.entitlements --sign "$ID" $APP
codesign --verify --deep --strict $APP && echo "Built $(pwd)/$APP"
[ -n "$NO_UNREGISTER" ] || pluginkit -r "$APPEX" 2>/dev/null || true
