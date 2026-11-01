#!/bin/sh
# Builds, signs, notarizes and packages SideNav into dist/SideNav-<version>.dmg
# Requires: SIGN_ID (Developer ID Application cert hash or name) and a notarytool
# keychain profile (default: sidenav-notary). Unlock the keychain first.
set -e
cd "$(dirname "$0")"
: "${SIGN_ID:?set SIGN_ID to your Developer ID Application identity}"
PROFILE="${NOTARY_PROFILE:-sidenav-notary}"
KC="${NOTARY_KEYCHAIN:-$HOME/Library/Keychains/sidenav.keychain-db}"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' host.plist)
DMG="dist/SideNav-$VERSION.dmg"
FLAGS="--timestamp --options runtime"

notarize() {
  xcrun notarytool submit "$1" --keychain-profile "$PROFILE" --keychain "$KC" --wait | tee /dev/stderr | grep -q "status: Accepted"
}

NO_UNREGISTER=1 SIGN_ID="$SIGN_ID" SIGN_FLAGS="$FLAGS" ./build.sh

rm -rf dist && mkdir -p dist/stage
ditto -c -k --keepParent SideNav.app dist/SideNav.zip
notarize dist/SideNav.zip
xcrun stapler staple SideNav.app

ditto SideNav.app dist/stage/SideNav.app
ln -s /Applications dist/stage/Applications
hdiutil create -volname "SideNav $VERSION" -srcfolder dist/stage -ov -format UDZO "$DMG"
codesign --force --timestamp --sign "$SIGN_ID" "$DMG"
notarize "$DMG"
xcrun stapler staple "$DMG"
rm -rf dist/stage dist/SideNav.zip
(cd dist && shasum -a 256 "SideNav-$VERSION.dmg" > "SideNav-$VERSION.dmg.sha256")
spctl -a -vv -t open --context context:primary-signature "$DMG" 2>&1 | head -2
echo "Release artifact: $(pwd)/$DMG"
