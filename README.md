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

## Production APK (real device)

Default API URL is production (`https://servecafe.com/backend-mobile-api/api`).

```bash
cd mobile-app
flutter pub get
flutter build apk --release
```

Install the APK from:

`build/app/outputs/flutter-apk/app-release.apk`

Copy to your phone (USB, AirDrop, cloud) and open it. Enable “Install unknown apps” if Android asks.

Start the API first from `backend-api/` on port 8001.

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
