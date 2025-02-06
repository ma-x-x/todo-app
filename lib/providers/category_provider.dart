import 'package:flutter/foundation.dart' hide Category;

import '../api/api_client.dart';
import '../api/category_api.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryApi _categoryApi;
  final StorageService _storage = StorageService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider() : _categoryApi = CategoryApi(ApiClient()) {
    loadCategories();
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('开始加载分类...');
      _categories = await _categoryApi.getCategories();
      await _storage.saveCategories(_categories);
      print('成功加载分类: ${_categories.length}个项目');
      notifyListeners();
    } catch (e) {
      print('加载分类失败: $e');
      _error = e.toString();
      _loadCachedCategories();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadCachedCategories() {
    final cachedCategories = _storage.getCategories();
    if (cachedCategories != null) {
      _categories = cachedCategories;
      notifyListeners();
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
        category.id!,
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
    _categories =
        categoriesData.map((json) => Category.fromJson(json)).toList();
    await _storage.saveCategories(_categories);
    notifyListeners();
  }
}
