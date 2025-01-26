import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<Response> login(String username, String password) {
    return _client.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> register(String username, String password, String email) {
    return _client.post('/auth/register', data: {
      'username': username,
      'password': password,
      'email': email,
    });
  }
} 