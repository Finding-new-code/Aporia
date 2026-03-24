import 'dart:async';
import 'package:aporia/core/network/api_client.dart';
import 'package:dio/dio.dart';

class AuthStore {
  bool isAuthenticated = false;
  String? userName;
  String? userEmail;
  String? error;
  bool isLoading = false;
}

/// Standalone auth state manager (not using DataFlow singleton to avoid
/// overwriting the single global store slot).
class AuthDataflow {
  AuthDataflow._();

  static final AuthStore _store = AuthStore();
  static AuthStore get store => _store;

  static final _controller = StreamController<AuthStore>.broadcast();
  static Stream<AuthStore> get stream => _controller.stream;

  static void _notify() => _controller.add(_store);

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    _store.isLoading = true;
    _store.error = null;
    _notify();

    try {
      final response = await ApiClient().post(
        '/auth/login',
        data: {'email': email, 'password': password, 'rememberMe': true},
      );

      if (response.statusCode == 200) {
        _store.isAuthenticated = true;
        _store.userName = response.data['user']['name'];
        _store.userEmail = response.data['user']['email'];
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['error'] != null) {
        _store.error = e.response?.data['error'].toString();
      } else {
        _store.error = 'Login failed. Please check your connection.';
      }
      rethrow;
    } catch (e) {
      _store.error = 'An unexpected error occurred.';
      rethrow;
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }

  static void logout() {
    _store.isAuthenticated = false;
    _store.userName = null;
    _store.userEmail = null;
    _store.error = null;
    _notify();
  }
}

// Keep a thin shim so LoginPage still compiles without changes
class LoginAction {
  final String email;
  final String password;
  LoginAction({required this.email, required this.password});

  Future<void> execute() =>
      AuthDataflow.login(email: email, password: password);
}
