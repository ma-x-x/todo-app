import 'package:flutter/foundation.dart' hide Category;
import '../api/category_api.dart';
import '../api/api_client.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryApi _categoryApi;
  final StorageService _storage = StorageService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider() : _categoryApi = CategoryApi(ApiClient()) {
    _loadCachedCategories();
  }

  void _loadCachedCategories() {
    final cachedCategories = _storage.getCategories();
    if (cachedCategories != null) {
      _categories = cachedCategories;
      notifyListeners();
    }
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _categoryApi.getCategories();
      final List<dynamic> data = response.data['items'];
      _categories = data.map((json) => Category.fromJson(json)).toList();
      
      // 缓存数据
      await _storage.saveCategories(_categories);
      
      notifyListeners();
    } catch (e) {
      _error = '获取分类列表失败：${e.toString()}';
      print(_error);
      // 如果网络请求失败，尝试使用缓存数据
      _loadCachedCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(String name, String? color) async {
    try {
      final response = await _categoryApi.createCategory({
        'name': name,
        'color': color,
      });
      final newCategory = Category.fromJson(response.data['category']);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoryApi.updateCategory(category.id!, {
        'name': category.name,
        'color': category.color,
      });
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryApi.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  Future<void> importCategories(List<dynamic> categoriesData) async {
    _categories = categoriesData.map((json) => Category.fromJson(json)).toList();
    await _storage.saveCategories(_categories);
    notifyListeners();
  }
} 