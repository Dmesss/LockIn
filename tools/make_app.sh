#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$DIR"

echo "Building LockIn for macOS..."
swift build -c release

APP_NAME="LockIn"
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

rm -rf "${APP_DIR}" dist/DuckPet.app
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp ".build/release/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"

if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"
fi

cat << 'PLIST' > "${CONTENTS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>LockIn</string>
    <key>CFBundleIdentifier</key>
    <string>com.dmess.LockIn</string>
    <key>CFBundleName</key>
    <string>LockIn</string>
    <key>CFBundleDisplayName</key>
    <string>LockIn</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSCameraUsageDescription</key>
    <string>Camera access is needed for the Quick Mirror feature in the Notch Dynamic Island.</string>
    <key>NSLocationUsageDescription</key>
    <string>LockIn uses your real-time location to display accurate local weather on your Dynamic Island.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>LockIn uses your real-time location to display accurate local weather on your Dynamic Island.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>LockIn uses your real-time location to display accurate local weather on your Dynamic Island.</string>
</dict>
</plist>
PLIST

# Ad-hoc codesign the bundle so macOS recognizes a consistent signature identity
codesign --force --deep -s - "${APP_DIR}"

echo "Successfully built and signed dist/LockIn.app!"
