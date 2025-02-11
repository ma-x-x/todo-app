import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi;
  final StorageService _storage;
  final ApiClient _apiClient;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  Timer? _refreshTimer;

  AuthProvider({
    required ApiClient apiClient,
    required StorageService storage,
  })  : _authApi = AuthApi(apiClient),
        _storage = storage,
        _apiClient = apiClient {
    _loadStoredAuth();
    _setupTokenRefresh();
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authApi.login(username, password);
      final token = response['token'].toString().trim();
      final userData = Map<String, dynamic>.from(response['user'] as Map);

      await _storage.saveToken(token);
      await _storage.saveUser(userData);

      _currentUser = User.fromJson(userData);
      _setupTokenRefresh();

      notifyListeners();
      print('Auth state updated: isAuthenticated = $isAuthenticated');
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
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
      _isLoading = true;
      notifyListeners();

      await _storage.deleteToken();
      await _storage.deleteUser();
      _currentUser = null;
      _refreshTimer?.cancel();

      _apiClient.clearAuth();

      notifyListeners();
    } catch (e) {
      print('退出登录失败: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<void> _setupTokenRefresh() async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _refreshToken(),
    );
  }

  Future<void> _refreshToken() async {
    final token = await _storage.getToken();
    if (token != null) {
      try {
        final user = await _authApi.validateToken(token);
        _currentUser = user;
        await _storage.saveToken(token);
        await _storage.saveUser(user.toJson());
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<void> restoreAuthState() async {
    final token = await _storage.getToken();
    if (token != null) {
      try {
        final user = await _authApi.validateToken(token);
        _currentUser = user;
        _setupTokenRefresh();
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }
}
