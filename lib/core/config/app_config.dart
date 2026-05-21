import 'package:serve_cafe_mobile/core/config/api_config.dart';

/// App-wide configuration.
///
/// **Change API URL for production:** edit [ApiConfig.defaultApiBaseUrl] or
/// [ApiConfig.productionApiBaseUrl] in [api_config.dart], or pass at run/build:
///
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://your-domain.com/api
/// flutter build apk --dart-define=API_BASE_URL=https://your-domain.com/api
/// ```
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: ApiConfig.defaultApiBaseUrl,
  );
}
