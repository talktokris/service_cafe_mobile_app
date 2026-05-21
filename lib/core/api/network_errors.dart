import 'dart:io';

import 'package:dio/dio.dart';

/// User-facing messages for network and API connectivity issues.
class NetworkMessages {
  static const noInternet =
      'No internet connection. Please turn on Wi‑Fi or mobile data and try again.';

  static const serverUnreachable =
      'Unable to reach the Serve Cafe server. Check your connection or try again in a few minutes.';

  static const serverTimeout =
      'The server is taking too long to respond. Please try again in a moment.';

  static const sslError =
      'Secure connection to the server failed. Please contact support if this continues.';
}

String resolveApiError(Object error) {
  if (error is! DioException) {
    return error.toString();
  }

  final dio = error;

  if (dio.response?.data is Map) {
    final data = dio.response!.data as Map;
    final msg = data['message'];
    if (msg != null && msg.toString().trim().isNotEmpty) {
      final text = msg.toString().trim();
      if (text.toLowerCase() == 'server error') {
        return 'The server could not complete sign in. Please try again in a few minutes or contact support.';
      }
      return text;
    }
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
    }
  }

  switch (dio.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkMessages.serverTimeout;
    case DioExceptionType.badCertificate:
      return NetworkMessages.sslError;
    case DioExceptionType.connectionError:
      return _connectionErrorMessage(dio);
    case DioExceptionType.unknown:
      if (dio.error is HandshakeException) {
        return NetworkMessages.sslError;
      }
      if (dio.error is SocketException) {
        return _socketMessage(dio.error! as SocketException);
      }
      break;
    default:
      break;
  }

  return dio.message ?? 'Something went wrong. Please try again.';
}

String _connectionErrorMessage(DioException dio) {
  final inner = dio.error;
  if (inner is HandshakeException) {
    return NetworkMessages.sslError;
  }
  if (inner is SocketException) {
    return _socketMessage(inner);
  }
  // Device may have mobile data but API still unreachable (wrong host, firewall, missing permission).
  return NetworkMessages.serverUnreachable;
}

String _socketMessage(SocketException e) {
  final msg = e.message.toLowerCase();
  final os = e.osError?.message.toLowerCase() ?? '';

  if (os.contains('network is unreachable') ||
      msg.contains('network is unreachable')) {
    return NetworkMessages.noInternet;
  }
  if (msg.contains('failed host lookup') ||
      msg.contains('no address associated with hostname')) {
    return NetworkMessages.serverUnreachable;
  }
  if (msg.contains('connection refused') ||
      msg.contains('software caused connection abort')) {
    return NetworkMessages.serverUnreachable;
  }
  if (msg.contains('connection timed out') || msg.contains('timed out')) {
    return NetworkMessages.serverTimeout;
  }

  final addr = e.address?.address;
  if (addr == '127.0.0.1' || addr == '10.0.2.2') {
    return NetworkMessages.serverUnreachable;
  }

  return NetworkMessages.serverUnreachable;
}
