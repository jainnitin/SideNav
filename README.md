# SideNav

Safari extension that makes the back and forward side buttons on your mouse navigate back and forward in Safari.

## Install

1. Download the latest `.dmg` from [Releases](https://github.com/jainnitin/SideNav/releases).
2. Drag SideNav to Applications and open it.
3. In Safari's extension settings, tick SideNav and allow it on every website.

Requires macOS 14 or later. The app is signed and notarized.

## Updates

Opening the SideNav app checks GitHub for a newer release and links to the download. Replace the app in Applications to update.

## Privacy

The extension has no network access and stores nothing. The app makes one request to api.github.com to check for a new release. No analytics.

## Build

    ./build.sh                       # local build (enable Develop > Allow Unsigned Extensions)
    SIGN_ID=<identity> ./release.sh  # signed, notarized DMG in dist/

## License

MIT
