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

/// Standalone auth state manager.
/// Uses its own static store to avoid overwriting the single DataFlow global slot.
class AuthDataflow {
  AuthDataflow._();

  static final AuthStore _store = AuthStore();
  static AuthStore get store => _store;

  static final _controller = StreamController<AuthStore>.broadcast();
  static Stream<AuthStore> get stream => _controller.stream;

  static void _notify() => _controller.add(_store);

  /// Extracts a human-readable error string from a DioException.
  static String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    return fallback;
  }

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
      _store.error = _errorMessage(e, 'Login failed. Please check your connection.');
      rethrow;
    } catch (e) {
      _store.error = 'An unexpected error occurred.';
      rethrow;
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }

  static Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _store.isLoading = true;
    _store.error = null;
    _notify();
    try {
      final response = await ApiClient().post(
        '/auth/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _store.isAuthenticated = true;
        _store.userName = response.data['user']['name'];
        _store.userEmail = response.data['user']['email'];
      }
    } on DioException catch (e) {
      _store.error = _errorMessage(e, 'Sign up failed. Please try again.');
      rethrow;
    } catch (e) {
      _store.error = 'An unexpected error occurred.';
      rethrow;
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }

  /// Logs the user out server-side and clears local auth state.
  /// Always succeeds locally even if the network call fails.
  static Future<void> logout() async {
    _store.isLoading = true;
    _notify();
    try {
      await ApiClient().post('/auth/logout');
    } catch (_) {
      // Best-effort — ignore network errors on logout
    } finally {
      _store
        ..isAuthenticated = false
        ..userName = null
        ..userEmail = null
        ..error = null
        ..isLoading = false;
      _notify();
    }
  }

  /// Fetches the currently authenticated user from the backend.
  /// Silently clears auth state if the session is expired/invalid.
  static Future<void> getCurrentUser() async {
    _store.isLoading = true;
    _notify();
    try {
      final response = await ApiClient().get('/auth/me');
      if (response.statusCode == 200) {
        _store.isAuthenticated = true;
        _store.userName = response.data['user']['name'];
        _store.userEmail = response.data['user']['email'];
      }
    } catch (_) {
      _store.isAuthenticated = false;
      _store.userName = null;
      _store.userEmail = null;
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }

  static Future<void> forgotPassword(String email) async {
    _store.isLoading = true;
    _store.error = null;
    _notify();
    try {
      await ApiClient().post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      _store.error = _errorMessage(e, 'Failed to send reset email.');
      rethrow;
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }

  static Future<void> resetPassword(String token, String newPassword) async {
    _store.isLoading = true;
    _store.error = null;
    _notify();
    try {
      await ApiClient().post(
        '/auth/reset-password',
        data: {'token': token, 'password': newPassword},
      );
    } on DioException catch (e) {
      _store.error = _errorMessage(e, 'Failed to reset password.');
      rethrow;
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }

  static Future<void> verifyEmail(String token) async {
    _store.isLoading = true;
    _store.error = null;
    _notify();
    try {
      await ApiClient().post('/auth/verify-email', data: {'token': token});
    } on DioException catch (e) {
      _store.error = _errorMessage(e, 'Failed to verify email.');
      rethrow;
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }
}

// ─── Action shims ─────────────────────────────────────────────────────────────

class LoginAction {
  final String email;
  final String password;
  LoginAction({required this.email, required this.password});
  Future<void> execute() => AuthDataflow.login(email: email, password: password);
}

class SignupAction {
  final String name;
  final String email;
  final String password;
  SignupAction({required this.name, required this.email, required this.password});
  Future<void> execute() =>
      AuthDataflow.signup(name: name, email: email, password: password);
}

class LogoutAction {
  Future<void> execute() => AuthDataflow.logout();
}

class GetCurrentUserAction {
  Future<void> execute() => AuthDataflow.getCurrentUser();
}

class ForgotPasswordAction {
  final String email;
  ForgotPasswordAction({required this.email});
  Future<void> execute() => AuthDataflow.forgotPassword(email);
}

class ResetPasswordAction {
  final String token;
  final String newPassword;
  ResetPasswordAction({required this.token, required this.newPassword});
  Future<void> execute() => AuthDataflow.resetPassword(token, newPassword);
}

class VerifyEmailAction {
  final String token;
  VerifyEmailAction({required this.token});
  Future<void> execute() => AuthDataflow.verifyEmail(token);
}
