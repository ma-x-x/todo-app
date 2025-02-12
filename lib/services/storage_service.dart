import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/todo.dart';
import '../routes/app_router.dart';

/// 存储服务类
/// 管理应用数据的本地存储，包括用户数据、设置和缓存
class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;

  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;

  // 缓存键
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _todosKey = 'cached_todos';
  static const String _categoriesKey = 'cached_categories';
  static const String _themeKey = 'app_theme';
  static const String _localeKey = 'app_locale';

  // 添加内存缓存
  final Map<String, dynamic> _memoryCache = {};

  // 添加缓存过期时间
  final Map<String, DateTime> _cacheExpiry = {};
  static const Duration _defaultExpiry = Duration(minutes: 30);

  /// 性能监控相关
  final Map<String, List<Duration>> _accessTimes = {};
  static const int _maxAccessTimeRecords = 100;

  // 添加缓存大小限制
  static const int _maxCacheSize = 100;

  // 私有构造函数
  StorageService._();

  /// 初始化存储服务
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
  }

  /// 优化的token存储
  Future<void> saveToken(String token) async {
    // 同时保存到内存缓存和安全存储
    _memoryCache[_tokenKey] = token;
    _cacheExpiry[_tokenKey] = DateTime.now().add(_defaultExpiry);
    await _secureStorage.write(key: _tokenKey, value: token);

    // 更新路由缓存
    await setValue('cached_route', AppRouter.home);
  }

  Future<String?> getToken() async {
    // 先检查内存缓存
    if (_memoryCache.containsKey(_tokenKey)) {
      final expiry = _cacheExpiry[_tokenKey];
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return _memoryCache[_tokenKey] as String?;
      }
    }

    // 从安全存储读取
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      // 更新内存缓存
      _memoryCache[_tokenKey] = token;
      _cacheExpiry[_tokenKey] = DateTime.now().add(_defaultExpiry);
    }
    return token;
  }

  Future<void> deleteToken() async {
    // 清除所有相关缓存
    _memoryCache.remove(_tokenKey);
    _cacheExpiry.remove(_tokenKey);
    await _secureStorage.delete(key: _tokenKey);
    await remove('cached_route');
  }

  /// 优化的用户信息缓存
  Future<void> saveUser(Map<String, dynamic> user) async {
    try {
      final jsonStr = jsonEncode(user);
      _memoryCache[_userKey] = user;
      _cacheExpiry[_userKey] = DateTime.now().add(_defaultExpiry);
      await _prefs.setString(_userKey, jsonStr);
    } catch (e) {
      print('保存用户信息失败: $e');
      rethrow;
    }
  }

  Map<String, dynamic>? getUser() {
    // 先检查内存缓存
    if (_memoryCache.containsKey(_userKey)) {
      final expiry = _cacheExpiry[_userKey];
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return _memoryCache[_userKey] as Map<String, dynamic>;
      }
      _memoryCache.remove(_userKey);
      _cacheExpiry.remove(_userKey);
    }

    try {
      final userStr = _prefs.getString(_userKey);
      if (userStr == null) return null;

      final user = jsonDecode(userStr) as Map<String, dynamic>;
      _memoryCache[_userKey] = user;
      _cacheExpiry[_userKey] = DateTime.now().add(_defaultExpiry);
      return user;
    } catch (e) {
      print('读取用户信息失败: $e');
      return null;
    }
  }

  Future<void> deleteUser() async {
    await _prefs.remove(_userKey);
  }

  /// 优化的 Todo 列表缓存
  Future<void> saveTodos(List<Todo> todos) async {
    try {
      final todosJson = todos.map((todo) => todo.toJson()).toList();
      final jsonStr = jsonEncode(todosJson);

      // 更新内存缓存
      _memoryCache[_todosKey] = todos;
      _cacheExpiry[_todosKey] = DateTime.now().add(_defaultExpiry);

      // 持久化存储
      await _prefs.setString(_todosKey, jsonStr);
    } catch (e) {
      print('保存待办列表失败: $e');
      rethrow;
    }
  }

  List<Todo>? getTodos() {
    // 先检查内存缓存
    if (_memoryCache.containsKey(_todosKey)) {
      final expiry = _cacheExpiry[_todosKey];
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return _memoryCache[_todosKey] as List<Todo>;
      }
      _memoryCache.remove(_todosKey);
      _cacheExpiry.remove(_todosKey);
    }

    // 从持久化存储读取
    try {
      final todosStr = _prefs.getString(_todosKey);
      if (todosStr == null) return null;

      final todosJson = jsonDecode(todosStr) as List;
      final todos = todosJson
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();

      // 加入内存缓存
      _memoryCache[_todosKey] = todos;
      _cacheExpiry[_todosKey] = DateTime.now().add(_defaultExpiry);

      return todos;
    } catch (e) {
      print('读取待办列表失败: $e');
      return null;
    }
  }

  Future<void> deleteTodos() async {
    await _prefs.remove(_todosKey);
  }

  /// 优化的分类列表缓存
  Future<void> saveCategories(List<Category> categories) async {
    try {
      final categoriesJson = categories.map((cat) => cat.toJson()).toList();
      final jsonStr = jsonEncode(categoriesJson);

      // 更新内存缓存
      _memoryCache[_categoriesKey] = categories;
      _cacheExpiry[_categoriesKey] = DateTime.now().add(_defaultExpiry);

      // 持久化存储
      await _prefs.setString(_categoriesKey, jsonStr);
    } catch (e) {
      print('保存分类列表失败: $e');
      rethrow;
    }
  }

  List<Category>? getCategories() {
    // 先检查内存缓存
    if (_memoryCache.containsKey(_categoriesKey)) {
      final expiry = _cacheExpiry[_categoriesKey];
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return _memoryCache[_categoriesKey] as List<Category>;
      }
      _memoryCache.remove(_categoriesKey);
      _cacheExpiry.remove(_categoriesKey);
    }

    // 从持久化存储读取
    try {
      final categoriesStr = _prefs.getString(_categoriesKey);
      if (categoriesStr == null) return null;

      final categoriesJson = jsonDecode(categoriesStr) as List;
      final categories = categoriesJson
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();

      // 加入内存缓存
      _memoryCache[_categoriesKey] = categories;
      _cacheExpiry[_categoriesKey] = DateTime.now().add(_defaultExpiry);

      return categories;
    } catch (e) {
      print('读取分类列表失败: $e');
      return null;
    }
  }

  Future<void> deleteCategories() async {
    await _prefs.remove(_categoriesKey);
  }

  /// 优化的主题设置缓存
  Future<void> saveThemeMode(String themeMode) async {
    await setValue(_themeKey, themeMode, expiry: const Duration(days: 365));
  }

  /// 优化的语言设置缓存
  Future<void> saveLocale(String locale) async {
    await setValue(_localeKey, locale, expiry: const Duration(days: 365));
  }

  // 清除所有缓存
  Future<void> clearAll() async {
    _memoryCache.clear();
    _cacheExpiry.clear();
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  /// 优化的存储方法
  Future<void> setValue<T>(String key, T value, {Duration? expiry}) async {
    try {
      // 更新内存缓存
      _memoryCache[key] = value;
      _cacheExpiry[key] = DateTime.now().add(expiry ?? _defaultExpiry);

      // 异步写入持久化存储
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else {
        throw UnsupportedError('Unsupported type: ${value.runtimeType}');
      }
    } catch (e) {
      print('存储失败: $e');
      rethrow;
    }
  }

  /// 记录访问时间
  void _recordAccessTime(String key, Duration duration) {
    if (!_accessTimes.containsKey(key)) {
      _accessTimes[key] = [];
    }
    final times = _accessTimes[key]!;
    times.add(duration);
    if (times.length > _maxAccessTimeRecords) {
      times.removeAt(0);
    }
  }

  /// 获取性能统计信息
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    for (final entry in _accessTimes.entries) {
      final times = entry.value;
      if (times.isEmpty) continue;

      stats[entry.key] = {
        'avgTime': times.reduce((a, b) => a + b) ~/ times.length,
        'maxTime': times.reduce((a, b) => a > b ? a : b),
        'minTime': times.reduce((a, b) => a < b ? a : b),
        'accessCount': times.length,
      };
    }
    return stats;
  }

  /// 使用 LRU 缓存策略
  void _addToCache(String key, dynamic value, Duration expiry) {
    if (_memoryCache.length >= _maxCacheSize) {
      // 移除最早的缓存
      final oldestKey = _cacheExpiry.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _memoryCache.remove(oldestKey);
      _cacheExpiry.remove(oldestKey);
    }

    _memoryCache[key] = value;
    _cacheExpiry[key] = DateTime.now().add(expiry);
  }

  /// 优化值读取方法
  T? getValue<T>(String key) {
    final stopwatch = Stopwatch()..start();
    try {
      final value = _memoryCache[key];
      final expiry = _cacheExpiry[key];

      if (value != null && expiry != null && expiry.isAfter(DateTime.now())) {
        return value as T?;
      }

      // 缓存未命中或已过期，从持久化存储读取
      final persistedValue = _prefs.get(key) as T?;
      if (persistedValue != null) {
        _addToCache(key, persistedValue, _defaultExpiry);
      }
      return persistedValue;
    } finally {
      stopwatch.stop();
      _recordAccessTime(key, stopwatch.elapsed);
    }
  }

  /// 清理过期缓存
  void cleanExpiredCache() {
    final now = DateTime.now();
    _cacheExpiry.removeWhere((key, expiry) {
      if (expiry.isBefore(now)) {
        _memoryCache.remove(key);
        return true;
      }
      return false;
    });
  }

  /// 优化的对象存储方法
  Future<void> saveObject<T>(
    String key,
    T object,
    T Function(Map<String, dynamic>) fromJson, {
    Duration? expiry,
  }) async {
    try {
      final jsonStr = jsonEncode(object);
      _memoryCache[key] = object;
      _cacheExpiry[key] = DateTime.now().add(expiry ?? _defaultExpiry);
      await _prefs.setString(key, jsonStr);
    } catch (e) {
      print('存储对象失败: $e');
      rethrow;
    }
  }

  /// 优化的对象读取方法
  T? getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // 先检查内存缓存
    if (_memoryCache.containsKey(key)) {
      final expiry = _cacheExpiry[key];
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return _memoryCache[key] as T;
      }
      _memoryCache.remove(key);
      _cacheExpiry.remove(key);
    }

    // 从持久化存储读取
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final object = fromJson(json);
      // 加入内存缓存
      _memoryCache[key] = object;
      _cacheExpiry[key] = DateTime.now().add(_defaultExpiry);
      return object;
    } catch (e) {
      print('读取对象失败: $e');
      return null;
    }
  }

  /// 删除指定键的缓存
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    _cacheExpiry.remove(key);
    await _prefs.remove(key);
  }

  /// 批量删除缓存
  Future<void> removeMultiple(List<String> keys) async {
    for (final key in keys) {
      _memoryCache.remove(key);
      _cacheExpiry.remove(key);
    }
    await Future.wait(keys.map((key) => _prefs.remove(key)));
  }

  /// 检查缓存是否存在
  bool containsKey(String key) {
    return _memoryCache.containsKey(key) || _prefs.containsKey(key);
  }

  /// 获取缓存剩余有效时间
  Duration? getTimeToExpiry(String key) {
    final expiry = _cacheExpiry[key];
    if (expiry == null) return null;
    return expiry.difference(DateTime.now());
  }

  /// 更新缓存过期时间
  void updateExpiry(String key, Duration expiry) {
    if (_memoryCache.containsKey(key)) {
      _cacheExpiry[key] = DateTime.now().add(expiry);
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryItemCount': _memoryCache.length,
      'expiryItemCount': _cacheExpiry.length,
      'persistentItemCount': _prefs.getKeys().length,
      'memoryKeys': _memoryCache.keys.toList(),
      'expiryKeys': _cacheExpiry.keys.toList(),
      'persistentKeys': _prefs.getKeys().toList(),
    };
  }

  /// 获取详细的缓存统计信息
  Map<String, dynamic> getDetailedStats() {
    return {
      'cache': getCacheStats(),
      'performance': getPerformanceStats(),
      'memory': {
        'cacheSize': _estimateMemoryUsage(),
      },
    };
  }

  /// 估算内存使用量（粗略计算）
  int _estimateMemoryUsage() {
    int size = 0;
    _memoryCache.forEach((key, value) {
      size += key.length;
      if (value is String) {
        size += value.length;
      } else if (value is List) {
        size += value.length * 8; // 假设每个元素平均8字节
      } else if (value is Map) {
        size += value.length * 16; // 假设每个键值对平均16字节
      }
    });
    return size;
  }

  /// 清理不常用的缓存
  void cleanInfrequentlyUsedCache() {
    final now = DateTime.now();
    final stats = getPerformanceStats();

    _cacheExpiry.removeWhere((key, expiry) {
      final keyStats = stats[key];
      if (keyStats == null) return false;

      // 如果某个键30分钟内访问次数少于5次，考虑清除
      if (keyStats['accessCount'] < 5 &&
          expiry.difference(now) < const Duration(minutes: 30)) {
        _memoryCache.remove(key);
        return true;
      }
      return false;
    });
  }

  /// 获取主题设置
  String? getThemeMode() {
    return getValue<String>(_themeKey);
  }

  /// 获取语言设置
  String? getLocale() {
    return getValue<String>(_localeKey);
  }
}
