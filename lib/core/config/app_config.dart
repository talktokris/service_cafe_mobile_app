class AppConfig {
  /// Android emulator: use http://10.0.2.2:8001/api
  /// iOS simulator / desktop: http://127.0.0.1:8001/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8001/api',
  );
}
