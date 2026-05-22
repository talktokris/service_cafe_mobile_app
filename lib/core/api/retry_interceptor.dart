import 'package:dio/dio.dart';

/// Retries transient failures (timeouts, connection drops) on slow networks.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 800),
  });

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  static const _retryKey = 'retryCount';

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.extra[_retryKey] is int &&
        (err.requestOptions.extra[_retryKey] as int) >= maxRetries) {
      return false;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        return code == 408 || code == 502 || code == 503 || code == 504;
      default:
        return false;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    final attempt = (options.extra[_retryKey] as int? ?? 0) + 1;
    options.extra[_retryKey] = attempt;

    await Future<void>.delayed(baseDelay * attempt);

    try {
      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }
}
