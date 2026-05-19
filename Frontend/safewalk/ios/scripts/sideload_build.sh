#!/bin/bash
#
# Build Safewalk for sideloading on personal iPhone (no paid Apple Developer account)
#
# Usage:
#   bash ios/scripts/sideload_build.sh
#
# Prerequisites:
#   - Xcode with your free Apple ID added (Xcode > Settings > Accounts)
#   - Flutter SDK installed and on PATH
#   - firebase.env.json configured (ios/scripts/generate_google_service_info.sh runs during build)
#
# What this does:
#   1. Temporarily patches the Xcode project for free-account-compatible settings
#   2. Generates GoogleService-Info.plist with the sideload bundle ID
#   3. Runs `flutter build ios --release --no-codesign`
#   4. Packages the .app into a standard .ipa at build/ios/safewalk-sideload.ipa
#   5. Restores all modified files to their original state
#
# After building, transfer safewalk-sideload.ipa to your iPhone and open in AltStore.
#
# Limitations with free Apple ID:
#   - Certificate expires every 7 days (AltStore auto-re-signs if AltServer runs)
#   - Push notifications do NOT work (requires paid membership)
#   - All other features (location, Mapbox, secure storage) work normally
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
IOS_DIR="$PROJECT_DIR/ios"
PBXPROJ="$IOS_DIR/Runner.xcodeproj/project.pbxproj"
PBXPROJ_BACKUP="${PBXPROJ}.bak"
BUILD_DIR="$PROJECT_DIR/build/ios"

SIDELOAD_BUNDLE_ID="com.safewalk.app.sideload"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

cleanup() {
  echo ""
  echo "Cleaning up..."

  # Restore pbxproj if backup exists
  if [ -f "$PBXPROJ_BACKUP" ]; then
    mv "$PBXPROJ_BACKUP" "$PBXPROJ"
    echo "  Restored project.pbxproj"
  fi

  # Restore firebase env if backup exists
  if [ -n "${FIREBASE_BACKUP:-}" ] && [ -f "$FIREBASE_BACKUP" ]; then
    mv "$FIREBASE_BACKUP" "$PROJECT_DIR/firebase.env.json"
    echo "  Restored firebase.env.json"
  fi
}

err_cleanup() {
  echo -e "\n${RED}ERROR${NC}: Build failed. Cleaning up..."
  cleanup
  exit 1
}

trap err_cleanup ERR

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Safewalk Sideload Build${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# ---- Prerequisites ----
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"

if ! command -v flutter &> /dev/null; then
  echo "  Error: Flutter not found on PATH"
  exit 1
fi

FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
echo "  Flutter: $FLUTTER_VERSION"

if ! xcode-select -p &> /dev/null; then
  echo "  Error: Xcode command line tools not found"
  exit 1
fi

XCODE_VERSION=$(xcodebuild -version 2>&1 | head -1)
echo "  Xcode: $XCODE_VERSION"

# Warn about AltStore
echo ""
echo -e "${YELLOW}[NOTE]${NC} After building, you'll need AltStore or similar to install:"
echo "  https://altstore.io"
echo ""

# ---- Read firebase.env.json ----
echo -e "${YELLOW}[2/6] Reading configuration...${NC}"

if [ ! -f "$PROJECT_DIR/firebase.env.json" ]; then
  echo "  Error: firebase.env.json not found"
  echo "  Copy firebase.env.json.template to firebase.env.json and fill in your values."
  exit 1
fi

# Backup firebase.env.json
FIREBASE_BACKUP=$(mktemp)
cp "$PROJECT_DIR/firebase.env.json" "$FIREBASE_BACKUP"
echo "  Backed up firebase.env.json"

# Read the sideload bundle ID from firebase.env.json or use default
FIREBASE_SIDELOAD_BUNDLE=$(python3 -c "
import json
try:
    cfg = json.load(open('$PROJECT_DIR/firebase.env.json'))
    print(cfg.get('FIREBASE_IOS_BUNDLE_ID_SIDELOAD', '$SIDELOAD_BUNDLE_ID'))
except:
    print('$SIDELOAD_BUNDLE_ID')
")
echo "  Sideload bundle ID: $FIREBASE_SIDELOAD_BUNDLE"

# ---- Patch Xcode project ----
echo -e "${YELLOW}[3/6] Patching Xcode project for sideload build...${NC}"

cp "$PBXPROJ" "$PBXPROJ_BACKUP"
echo "  Backed up project.pbxproj"

# Patch entitlements: replace Runner.entitlements with RunnerSideload.entitlements
sed -i '' 's/CODE_SIGN_ENTITLEMENTS = Runner\/Runner\.entitlements;/CODE_SIGN_ENTITLEMENTS = Runner\/RunnerSideload.entitlements;/g' "$PBXPROJ"
echo "  Switched entitlements to RunnerSideload.entitlements"

# Patch bundle ID
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\\.safewalk\\.app\\.debug;/PRODUCT_BUNDLE_IDENTIFIER = $FIREBASE_SIDELOAD_BUNDLE;/g" "$PBXPROJ"
echo "  Updated bundle ID to $FIREBASE_SIDELOAD_BUNDLE"

# Remove development team (comment out the line)
sed -i '' 's/^[[:space:]]*DEVELOPMENT_TEAM = [A-Z0-9]*;$/  DEVELOPMENT_TEAM = "";/g' "$PBXPROJ"
echo "  Cleared DEVELOPMENT_TEAM (you will pick your free team in Xcode)"

# ---- Generate GoogleService-Info.plist ----
echo -e "${YELLOW}[4/6] Generating GoogleService-Info.plist for sideload bundle...${NC}"

export FIREBASE_BUNDLE_OVERRIDE="$FIREBASE_SIDELOAD_BUNDLE"
bash "$SCRIPT_DIR/generate_google_service_info.sh"
echo "  Generated GoogleService-Info.plist with bundle ID: $FIREBASE_SIDELOAD_BUNDLE"

# ---- Build ----
echo -e "${YELLOW}[5/6] Building iOS app (no codesign)...${NC}"
echo "  This may take several minutes..."
echo ""

cd "$PROJECT_DIR"

flutter build ios --release --no-codesign

echo ""
echo -e "${GREEN}  Build complete!${NC}"

# ---- Package IPA ----
echo -e "${YELLOW}[6/6] Packaging IPA...${NC}"

IPA_DIR="$BUILD_DIR/ipa"
PAYLOAD_DIR="$IPA_DIR/Payload"
APP_BUNDLE="$BUILD_DIR/iphoneos/Runner.app"

if [ ! -d "$APP_BUNDLE" ]; then
  echo "  Error: Built app not found at $APP_BUNDLE"
  err_cleanup
fi

rm -rf "$IPA_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_BUNDLE" "$PAYLOAD_DIR/"

cd "$IPA_DIR"
zip -r "$BUILD_DIR/safewalk-sideload.ipa" Payload/ > /dev/null
cd "$PROJECT_DIR"

rm -rf "$IPA_DIR"

echo "  IPA created: build/ios/safewalk-sideload.ipa"

# ---- Restore ----
echo ""
cleanup

# ---- Done ----
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Build successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "IPA location: ${CYAN}build/ios/safewalk-sideload.ipa${NC}"
echo ""
echo -e "${YELLOW}Installation instructions:${NC}"
echo "  1. Install AltStore on your iPhone from https://altstore.io"
echo "  2. Transfer safewalk-sideload.ipa to your iPhone (AirDrop, iCloud, etc.)"
echo "  3. Open AltStore on iPhone → My Apps → tap + → select the .ipa"
echo "  4. Enter your free Apple ID credentials when prompted"
echo ""
echo -e "${YELLOW}Important notes:${NC}"
echo "  • The app certificate expires after 7 days"
echo "  • AltStore can auto-renew if AltServer runs on your Mac"
echo "  • Push notifications will NOT work (requires paid developer account)"
echo "  • All other features work normally"
echo ""
