# Serve Cafe Mobile

Flutter app for free and paid members.

## Run (local API)

```bash
cd mobile-app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8001/api
```

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001/api
```

## Production API

Release builds use **`https://servecafe.com/backend-mobile-api/api`** by default (`lib/core/config/api_config.dart`).

Override at build time:

```bash
--dart-define=API_BASE_URL=https://servecafe.com/backend-mobile-api/api
```

## Production APK (Android, real device)

```bash
cd mobile-app
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL=https://servecafe.com/backend-mobile-api/api
```

Install from `build/app/outputs/flutter-apk/app-release.apk` (USB, cloud, etc.). Enable “Install unknown apps” if prompted.

## Production iOS (iPhone, no App Store)

Requires **macOS**, **Xcode**, and an **Apple Developer** account (free or paid) for signing.

1. Open `ios/Runner.xcworkspace` in Xcode → **Signing & Capabilities** → select your **Team**.
2. For Ad Hoc installs, register each iPhone **UDID** in [Apple Developer](https://developer.apple.com) and use an Ad Hoc provisioning profile.

Build IPA:

```bash
cd mobile-app
chmod +x scripts/build_ios_release.sh
./scripts/build_ios_release.sh
```

Or manually:

```bash
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://servecafe.com/backend-mobile-api/api
```

Output: `build/ios/ipa/serve_cafe_mobile.ipa` (name may vary).

**Install on device**

- **USB + Xcode:** Window → Devices and Simulators → install the `.ipa` or run from Xcode.
- **Ad Hoc IPA:** AirDrop / Apple Configurator / AltStore / Sideloadly → on iPhone: Settings → General → VPN & Device Management → trust the developer profile.

Optional: edit `ios/ExportOptions-adhoc.plist` (`YOUR_TEAM_ID`) and export from Xcode Organizer if `flutter build ipa` needs custom export options.

## API base URL (backend)

Edit **`lib/core/config/api_config.dart`** to set local or production defaults:

- `defaultApiBaseUrl` — used when you run without `--dart-define`
- `productionApiBaseUrl` — set your hosted Laravel API URL before release

Override anytime at run or build:

```bash
flutter run --dart-define=API_BASE_URL=https://your-domain.com/api
flutter build apk --dart-define=API_BASE_URL=https://your-domain.com/api
```

The active URL is read in `lib/core/config/app_config.dart`.

## Features

- 5-tab navigation: Home, Orders, Earnings, Wallet, Account
- Sanctum token auth with secure storage
- Paid-only: Earnings, Cash Wallet, Badges (locked UI for free members)
- Brand colors: `#531414` / `#DE3032`

## App icon & splash

After changing `assets/images/art-logo.png` (splash & app icon) or `logo.png` (in-app headers), regenerate native assets:

```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

Then stop the app and run again (or reinstall on the emulator) so the home-screen icon and launch splash update.
