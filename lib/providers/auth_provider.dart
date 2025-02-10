import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi;
  final StorageService _storage = StorageService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider() : _authApi = AuthApi(ApiClient()) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final token = await _storage.getToken();
    if (token != null) {
      final userData = _storage.getUser();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        notifyListeners();
      }
    }
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authApi.login(username, password);

      // 确保正确获取 token 和 user 数据
      final token = response['token'] as String;
      final user = response['user'] as User;

      await _storage.saveToken(token);
      print('Token已保存: $token');

      await _storage.saveUser(user.toJson());
      _currentUser = user;
      print('用户数据已保存: $_currentUser');

      notifyListeners();
    } catch (e) {
      print('登录处理错误: $e');
      _error = '登录失败：${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String password, String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authApi.register(username, password, email);
      await login(username, password);
    } catch (e) {
      _error = '注册失败：${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteToken();
      await _storage.deleteUser();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('退出登录失败: $e');
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getToken();
    if (token != null) {
      final userData = _storage.getUser();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        notifyListeners();
      }
    }
  }
}
