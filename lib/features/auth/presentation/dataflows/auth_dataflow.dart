import 'package:dataflow/dataflow.dart';
import 'package:aporia/core/network/api_client.dart';
import 'package:dio/dio.dart';

class AuthStore extends DataStore {
  bool isAuthenticated = false;
  String? userName;
  String? userEmail;
  String? error;
}

void initAuthDataflow() {
  DataFlow.init<AuthStore>(AuthStore());
}

class LoginAction extends DataAction<AuthStore> {
  final String email;
  final String password;

  LoginAction({required this.email, required this.password});

  @override
  Future<void> execute() async {
    try {
      store.error = null;

      final response = await ApiClient().post(
        '/auth/login',
        data: {'email': email, 'password': password, 'rememberMe': true},
      );

      if (response.statusCode == 200) {
        store.isAuthenticated = true;
        store.userName = response.data['user']['name'];
        store.userEmail = response.data['user']['email'];
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['error'] != null) {
        store.error = e.response?.data['error'];
      } else {
        store.error = 'Login failed. Please check your connection.';
      }
      throw Exception(store.error);
    } catch (e) {
      store.error = 'An unexpected error occurred.';
      throw Exception(store.error);
    }
  }
}
