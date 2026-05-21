# Serve Cafe Mobile

Flutter app for free and paid members.

## Run

```bash
cd mobile-app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8001/api
```

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001/api
```

Start the API first from `backend-api/` on port 8001.

## Features

- 5-tab navigation: Home, Orders, Earnings, Wallet, Account
- Sanctum token auth with secure storage
- Paid-only: Earnings, Cash Wallet, Badges (locked UI for free members)
- Brand colors: `#531414` / `#DE3032`

## App icon & splash

After changing `assets/images/logo.png`, regenerate native assets:

```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

Then stop the app and run again (or reinstall on the emulator) so the home-screen icon and launch splash update.
