#!/usr/bin/env bash
# Production iOS build (API: https://servecafe.com/backend-mobile-api/api)
# Output: build/ios/ipa/*.ipa (install via Xcode, Apple Configurator, AltStore, etc.)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PRODUCTION_API_URL="${API_BASE_URL:-https://servecafe.com/backend-mobile-api/api}"

echo "==> Serve Cafe iOS production build"
echo "    API_BASE_URL=${PRODUCTION_API_URL}"

flutter pub get

DART_DEFINES=(--dart-define="API_BASE_URL=${PRODUCTION_API_URL}")

# Release IPA (requires Apple Development Team in Xcode)
if flutter build ipa --release "${DART_DEFINES[@]}"; then
  echo ""
  echo "Done. IPA:"
  ls -la build/ios/ipa/*.ipa 2>/dev/null || ls -la build/ios/ipa/ 2>/dev/null || true
else
  echo ""
  echo "IPA export failed (usually missing code signing). Steps:"
  echo "  1. open ios/Runner.xcworkspace"
  echo "  2. Runner target → Signing & Capabilities → select Team"
  echo "  3. Re-run: ./scripts/build_ios_release.sh"
  echo ""
  echo "Building unsigned .app for manual archive in Xcode..."
  flutter build ios --release --no-codesign "${DART_DEFINES[@]}"
  echo "Unsigned app: build/ios/iphoneos/Runner.app"
  echo "In Xcode: Product → Archive → Distribute App → Ad Hoc / Development"
  exit 1
fi

echo ""
echo "Install on iPhone (no App Store):"
echo "  1. Register device UDID for Ad Hoc, or install via Xcode (USB)"
echo "  2. AirDrop / Configurator / AltStore / Sideloadly"
echo "  3. Settings → General → VPN & Device Management → trust developer"
