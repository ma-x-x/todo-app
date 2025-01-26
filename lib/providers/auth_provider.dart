import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
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

      // 添加调试输出
      print('Login response: ${response.data}');

      final token = response.data['token'] as String;
      await _storage.saveToken(token);

      // 保存用户信息
      if (response.data['user'] != null) {
        print('User data received: ${response.data['user']}');
        _currentUser = User.fromJson(response.data['user']);
        await _storage.saveUser(response.data['user']);
      } else {
        print('No user data in response');
      }

      notifyListeners();
    } catch (e) {
      print('Login error in provider: $e');
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
    await _storage.deleteToken();
    await _storage.deleteUser();
    _currentUser = null;
    notifyListeners();
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
