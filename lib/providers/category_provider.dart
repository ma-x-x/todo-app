import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' hide Category;

import '../api/category_api.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

/// 分类管理器
/// 负责管理待办事项的分类数据，包括加载、创建、更新和删除分类
/// 支持本地缓存和在线同步
class CategoryProvider with ChangeNotifier {
  final CategoryApi _categoryApi;
  bool _isLoading = false;
  String? _error;
  final List<Category> _categories = [];
  bool _isInitialized = false;
  final StorageService _storage = StorageService();

  // 添加缓存过期时间
  static const Duration _cacheExpiry = Duration(minutes: 30);
  DateTime? _lastLoadTime;
  DateTime? _lastNotification;
  bool _batchNotify = false;

  /// 获取所有分类
  List<Category> get categories => _categories;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 获取错误信息
  String? get error => _error;

  bool get isInitialized => _isInitialized;

  CategoryProvider({required CategoryApi categoryApi})
      : _categoryApi = categoryApi;

  /// 优化初始化加载
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      // 先加载缓存数据
      _loadCachedCategories();

      // 检查是否需要从服务器刷新数据
      if (_shouldRefreshData()) {
        // 使用异步加载避免阻塞UI
        unawaited(_refreshDataInBackground());
      }

      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      print('加载分类失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 从缓存加载数据
  void _loadCachedCategories() {
    final cached = _storage.getCategories();
    if (cached != null) {
      _categories.clear();
      _categories.addAll(cached);
      notifyListeners();
    }
  }

  /// 判断是否需要刷新数据
  bool _shouldRefreshData() {
    if (_lastLoadTime == null) return true;
    return DateTime.now().difference(_lastLoadTime!) > _cacheExpiry;
  }

  /// 后台刷新数据
  Future<void> _refreshDataInBackground() async {
    try {
      final categories = await _categoryApi.getCategories();
      beginBatchUpdate();
      _categories.clear();
      _categories.addAll(categories);
      await _storage.saveCategories(_categories);
      _lastLoadTime = DateTime.now();
    } finally {
      endBatchUpdate();
    }
  }

  /// 批量更新支持
  void beginBatchUpdate() {
    _batchNotify = true;
  }

  void endBatchUpdate() {
    _batchNotify = false;
    notifyListeners();
  }

  /// 优化通知逻辑
  @override
  void notifyListeners() {
    if (_batchNotify) return;

    // 添加节流，避免频繁刷新
    if (_lastNotification == null ||
        DateTime.now().difference(_lastNotification!) >
            const Duration(milliseconds: 100)) {
      super.notifyListeners();
      _lastNotification = DateTime.now();
    }
  }

  Future<void> createCategory(String name, {String? color}) async {
    try {
      final newCategory = await _categoryApi.createCategory({
        'name': name,
        'color': color,
      });
      _categories.add(newCategory);
      await _storage.saveCategories(_categories);
      notifyListeners();
    } catch (e) {
      print('创建分类失败: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      final updatedCategory = await _categoryApi.updateCategory(
        category.id,
        category.toJson(),
      );
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        await _storage.saveCategories(_categories);
        notifyListeners();
      }
    } catch (e) {
      print('更新分类失败: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryApi.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      await _storage.saveCategories(_categories);
      notifyListeners();
    } catch (e) {
      print('删除分类失败: $e');
      rethrow;
    }
  }

  Future<void> importCategories(List<dynamic> categoriesData) async {
    _categories.clear();
    _categories
        .addAll(categoriesData.map((json) => Category.fromJson(json)).toList());
    await _storage.saveCategories(_categories);
    notifyListeners();
  }
}
