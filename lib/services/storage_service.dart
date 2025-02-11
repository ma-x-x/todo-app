import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/todo.dart';

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

  // 私有构造函数
  StorageService._();

  /// 初始化存储服务
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
  }

  /// 保存认证令牌
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// 获取存储的认证令牌
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // 用户信息缓存
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  Map<String, dynamic>? getUser() {
    final userStr = _prefs.getString(_userKey);
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  Future<void> deleteUser() async {
    await _prefs.remove(_userKey);
  }

  // Todo列表缓存
  Future<void> saveTodos(List<Todo> todos) async {
    final todosJson = todos.map((todo) => todo.toJson()).toList();
    await _prefs.setString(_todosKey, jsonEncode(todosJson));
  }

  List<Todo>? getTodos() {
    final todosStr = _prefs.getString(_todosKey);
    if (todosStr == null) return null;
    final todosJson = jsonDecode(todosStr) as List;
    return todosJson.map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> deleteTodos() async {
    await _prefs.remove(_todosKey);
  }

  // 分类列表缓存
  Future<void> saveCategories(List<Category> categories) async {
    final categoriesJson = categories.map((cat) => cat.toJson()).toList();
    await _prefs.setString(_categoriesKey, jsonEncode(categoriesJson));
  }

  List<Category>? getCategories() {
    final categoriesStr = _prefs.getString(_categoriesKey);
    if (categoriesStr == null) return null;
    final categoriesJson = jsonDecode(categoriesStr) as List;
    return categoriesJson.map((json) => Category.fromJson(json)).toList();
  }

  Future<void> deleteCategories() async {
    await _prefs.remove(_categoriesKey);
  }

  // 主题设置
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  String? getThemeMode() {
    return _prefs.getString(_themeKey);
  }

  // 语言设置
  Future<void> saveLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  String? getLocale() {
    return _prefs.getString(_localeKey);
  }

  // 清除所有缓存
  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  // 使用泛型优化存储方法
  Future<void> setValue<T>(String key, T value) async {
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
  }

  T? getValue<T>(String key) {
    return _prefs.get(key) as T?;
  }

  /// 通用对象存储方法
  ///
  /// 类型参数:
  /// - T: 要存储的对象类型
  ///
  /// 参数:
  /// - key: 存储键
  /// - object: 要存储的对象
  /// - fromJson: 从JSON转换为对象的函数
  Future<void> saveObject<T>(
      String key, T object, T Function(Map<String, dynamic>) fromJson) async {
    final jsonStr = jsonEncode(object);
    await _prefs.setString(key, jsonStr);
  }

  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return fromJson(json);
  }
}
