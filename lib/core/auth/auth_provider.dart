import 'package:flutter/foundation.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/token_storage.dart';
import 'package:serve_cafe_mobile/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, this._tokenStorage);

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  UserModel? user;
  bool loading = false;
  String? error;
  bool initialized = false;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    try {
      final token = await _tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        await fetchMe();
      }
    } catch (_) {
      await _tokenStorage.deleteToken();
      user = null;
    } finally {
      loading = false;
      initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final body = await _api.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final data = body['data'] as Map<String, dynamic>;
      await _tokenStorage.saveToken(data['token'] as String);
      user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      return true;
    } catch (e) {
      error = ApiClient.friendlyError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMe() async {
    final body = await _api.get(ApiEndpoints.me);
    user = UserModel.fromJson(body['data'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (_) {}
    await _tokenStorage.deleteToken();
    user = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
