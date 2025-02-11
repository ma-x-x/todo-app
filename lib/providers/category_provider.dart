import 'package:flutter/foundation.dart' hide Category;

import '../api/category_api.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

/// 分类管理器
/// 负责管理待办事项的分类数据，包括加载、创建、更新和删除分类
class CategoryProvider with ChangeNotifier {
  final CategoryApi _categoryApi;
  final bool _isLoading = false;
  String? _error;
  final List<Category> _categories = [];
  bool _isInitialized = false;
  final StorageService _storage = StorageService();

  /// 获取所有分类
  List<Category> get categories => _categories;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 获取错误信息
  String? get error => _error;

  bool get isInitialized => _isInitialized;

  CategoryProvider({required CategoryApi categoryApi})
      : _categoryApi = categoryApi;

  Future<void> loadCategories() async {
    try {
      _loadCachedCategories();
      final categories = await _categoryApi.getCategories();

      _categories.clear();
      _categories.addAll(categories);
      _error = null;
      _isInitialized = true;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('加载分类失败: $e');
      rethrow;
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

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    await loadCategories();
  }

  void _loadCachedCategories() {
    final cachedCategories = _storage.getCategories();
    if (cachedCategories != null) {
      _categories.clear();
      _categories.addAll(cachedCategories);
      notifyListeners();
    }
  }
}
