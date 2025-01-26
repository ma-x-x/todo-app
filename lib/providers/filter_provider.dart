import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/todo_filter.dart';

class FilterProvider with ChangeNotifier {
  TodoFilter _filter = TodoFilter.all;
  String _searchQuery = '';
  Category? _selectedCategory;
  String? _selectedPriority;

  TodoFilter get filter => _filter;
  String get searchQuery => _searchQuery;
  Category? get selectedCategory => _selectedCategory;
  String? get selectedPriority => _selectedPriority;

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
    _selectedCategory = null;
    _selectedPriority = null;
    notifyListeners();
  }
} 