import '../models/user.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  // 用户登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // 发送登录请求
      final response = await _client.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      // 返回token和用户信息
      return {
        'token': response.data['token'] as String,
        'user': response.data['user'] as Map<String, dynamic>,
      };
    } catch (e) {
      print('登录失败: $e');
      rethrow;
    }
  }

  // 用户注册
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

  // 验证token有效性
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
