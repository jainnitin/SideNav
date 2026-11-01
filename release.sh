#!/bin/sh
# Builds, signs, notarizes and packages dist/SideNav-<version>.dmg.
# Needs SIGN_ID (Developer ID Application identity) and a notarytool keychain profile.
set -e
cd "$(dirname "$0")"
: "${SIGN_ID:?set SIGN_ID to your Developer ID Application identity}"
PROFILE="${NOTARY_PROFILE:-sidenav-notary}"
KC="${NOTARY_KEYCHAIN:-$HOME/Library/Keychains/sidenav.keychain-db}"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' host.plist)
DMG="dist/SideNav-$VERSION.dmg"

notarize() {
  xcrun notarytool submit "$1" --keychain-profile "$PROFILE" --keychain "$KC" --wait | tee /dev/stderr | grep -q "status: Accepted"
}

SIGN_FLAGS="--timestamp --options runtime" ./build.sh
rm -rf dist && mkdir dist
ditto -c -k --keepParent SideNav.app dist/SideNav.zip
notarize dist/SideNav.zip
xcrun stapler staple SideNav.app
rm dist/SideNav.zip

./dmg.sh SideNav.app "$DMG"
codesign --force --timestamp --sign "$SIGN_ID" "$DMG"
notarize "$DMG"
xcrun stapler staple "$DMG"
echo "Built $DMG"
