/// Edit these URLs when deploying or switching environments.
///
/// At build/run time you can still override with:
///   flutter run --dart-define=API_BASE_URL=https://your-server.com/api
class ApiConfig {
  /// Local Laravel API (desktop / iOS simulator).
  static const String localApiBaseUrl = 'http://127.0.0.1:8001/api';

  /// Android emulator → host machine (10.0.2.2 maps to your PC localhost).
  static const String androidEmulatorApiBaseUrl = 'http://10.0.2.2:8001/api';

  /// Production — cPanel: public_html/backend-mobile-api → Laravel public/
  static const String productionApiBaseUrl = 'https://servecafe.com/backend-mobile-api/api';

  /// Default used when no --dart-define=API_BASE_URL is passed.
  /// Switch to [productionApiBaseUrl] for store/release builds if you prefer.
  static const String defaultApiBaseUrl = localApiBaseUrl;
}
