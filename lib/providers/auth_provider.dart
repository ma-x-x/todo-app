import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/// 认证状态管理器
/// 负责处理用户的登录、注册、登出等认证相关操作，并管理认证状态
///
/// 主要功能：
/// - 用户登录/注册/登出
/// - 自动加载存储的认证信息
/// - 管理令牌的自动刷新
/// - 维护当前用户状态
class AuthProvider with ChangeNotifier {
  final AuthApi _authApi;
  final StorageService _storage;
  final ApiClient _apiClient;

  /// 当前登录用户
  User? _currentUser;

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 令牌刷新定时器
  Timer? _refreshTimer;

  /// 添加令牌刷新间隔常量
  static const refreshInterval = Duration(minutes: 30);

  AuthProvider({
    required ApiClient apiClient,
    required StorageService storage,
  })  : _authApi = AuthApi(apiClient),
        _storage = storage,
        _apiClient = apiClient {
    _loadStoredAuth();
    _setupTokenRefresh();
  }

  /// 从存储中加载认证信息
  /// 如果存在有效的token和用户数据，则恢复认证状态
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

  /// 获取当前用户
  User? get currentUser => _currentUser;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 获取错误信息
  String? get error => _error;

  /// 是否已认证
  bool get isAuthenticated => _currentUser != null;

  /// 添加错误处理方法
  void _handleError(String operation, dynamic error) {
    _error = '$operation失败: $error';
    print(_error);
  }

  /// 优化登录方法的错误处理
  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authApi.login(username, password);
      await _handleLoginResponse(response);
    } catch (e) {
      _handleError('登录', e);
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 抽取登录响应处理逻辑
  Future<void> _handleLoginResponse(Map<String, dynamic> response) async {
    final token = response['token'].toString().trim();
    final userData = Map<String, dynamic>.from(response['user'] as Map);

    await _storage.saveToken(token);
    await _storage.saveUser(userData);

    _currentUser = User.fromJson(userData);
    _setupTokenRefresh();
    notifyListeners();
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

      // 先清除认证状态
      _currentUser = null;
      _refreshTimer?.cancel();
      _refreshTimer = null;

      // 然后清除存储
      await _storage.deleteToken();
      await _storage.deleteUser();

      // 清除 API 客户端的认证信息
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

  /// 设置令牌自动刷新
  /// 每30分钟自动刷新一次令牌，确保用户会话持续有效
  Future<void> _setupTokenRefresh() async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _refreshToken(),
    );
  }

  /// 刷新认证令牌
  /// 如果刷新失败，将自动登出用户
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

  /// 添加会话有效性检查方法
  Future<bool> isSessionValid() async {
    final token = await _storage.getToken();
    if (token == null) return false;

    try {
      await _authApi.validateToken(token);
      return true;
    } catch (e) {
      return false;
    }
  }
}
