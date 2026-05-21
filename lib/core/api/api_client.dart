import 'package:dio/dio.dart';
import 'package:serve_cafe_mobile/core/api/network_errors.dart';
import 'package:serve_cafe_mobile/core/auth/token_storage.dart';
import 'package:serve_cafe_mobile/core/config/app_config.dart';

typedef OnUnauthorized = Future<void> Function();

class ApiClient {
  ApiClient(this._tokenStorage, {this.onUnauthorized});

  final TokenStorage _tokenStorage;
  final OnUnauthorized? onUnauthorized;

  late final Dio dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _tokenStorage.deleteToken();
          await onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final response = await dio.get(path, queryParameters: query);
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    final response = await dio.post(path, data: data);
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    final response = await dio.put(path, data: data);
    return _unwrap(response);
  }

  Map<String, dynamic> _unwrap(Response response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw DioException(requestOptions: response.requestOptions, message: 'Invalid response');
    }
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: body['message']?.toString() ?? 'Request failed',
      );
    }
    return body;
  }

  /// Maps API/network failures to clear user-facing text.
  static String friendlyError(Object error) => resolveApiError(error);
}
