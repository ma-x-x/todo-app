import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/todo_filter.dart';

/// 过滤器管理器
/// 负责管理待办事项的过滤条件，包括完成状态、搜索关键词、分类和优先级
///
/// 支持的过滤条件：
/// - 完成状态（全部/已完成/未完成）
/// - 搜索关键词
/// - 分类筛选
/// - 优先级筛选
class FilterProvider with ChangeNotifier {
  /// 完成状态过滤器
  TodoFilter _filter = TodoFilter.all;

  /// 搜索关键词
  String _searchQuery = '';

  /// 选中的分类
  Category? _selectedCategory;

  /// 选中的优先级
  String? _selectedPriority;

  TodoFilter get filter => _filter;
  String get searchQuery => _searchQuery;
  Category? get selectedCategory => _selectedCategory;
  String? get selectedPriority => _selectedPriority;

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty == true ||
        filter != null ||
        selectedCategory != null ||
        selectedPriority != null;
  }

  void setFilter(TodoFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedPriority(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void clearFilters() {
    _filter = TodoFilter.all;
    _searchQuery = '';
    _selectedCategory = null;
    _selectedPriority = null;
    notifyListeners();
  }
}
