import '../models/user.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      return {
        'token': response.data['token'] as String,
        'user': User.fromJson(response.data['user']),
      };
    } catch (e) {
      print('登录失败: $e');
      rethrow;
    }
  }

  Future<void> register(String username, String password, String email) async {
    try {
      await _client.post('/auth/register', data: {
        'username': username,
        'password': password,
        'email': email,
      });
    } catch (e) {
      print('注册失败: $e');
      rethrow;
    }
  }

  Future<User> validateToken(String token) async {
    try {
      final response = await _client.get('/auth/validate');
      return User.fromJson(response.data);
    } catch (e) {
      print('验证token失败: $e');
      rethrow;
    }
  }
}
