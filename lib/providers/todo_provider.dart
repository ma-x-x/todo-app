import 'package:flutter/foundation.dart' hide Category;

import '../api/todo_api.dart';
import '../models/category.dart';
import '../models/todo.dart';
import '../models/todo_filter.dart';
import '../providers/filter_provider.dart';
import '../services/network_service.dart';
import '../services/offline_manager.dart';
import '../services/storage_service.dart';

/// 待办事项管理器
/// 负责管理待办事项的数据，包括加载、创建、更新、删除等操作
/// 支持离线模式和数据同步
class TodoProvider with ChangeNotifier {
  final TodoApi _todoApi;
  final StorageService _storage = StorageService();

  /// 待办事项列表
  final List<Todo> _todos = [];

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 离线管理器
  final _offlineManager = OfflineManager();

  /// 网络服务
  final _network = NetworkService();

  /// 获取所有待办事项
  List<Todo> get todos => _todos;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 获取错误信息
  String? get error => _error;

  /// 添加自动加载标志
  bool _isInitialized = false;

  DateTime? _lastNotification;

  // 添加批量更新支持
  bool _batchNotify = false;
  final List<void Function()> _pendingUpdates = [];

  TodoProvider({required TodoApi todoApi}) : _todoApi = todoApi;

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      final todos = await _todoApi.getTodos();
      _todos.clear();
      _todos.addAll(todos);
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('加载待办事项失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodos() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final todos = await _todoApi.getTodos();
      _todos.clear();
      _todos.addAll(todos);
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('加载待办事项失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTodo(Todo todo, Category? category) async {
    try {
      if (!_network.hasConnection) {
        // 离线模式：保存到本地
        final localTodo = todo.copyWith(
          id: DateTime.now().millisecondsSinceEpoch,
          isOffline: true,
        );
        _todos.add(localTodo);
        await _storage.saveTodos(_todos);
        _offlineManager.addPendingChange('todo_create', localTodo.toJson());
        notifyListeners();
        return;
      }

      // 在线模式：正常创建
      final response = await _todoApi.createTodo(todo);
      _todos.add(response);
      await _storage.saveTodos(_todos);
      notifyListeners();
    } catch (e) {
      print('创建待办失败: $e');
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo, Category? category) async {
    try {
      // 保存原有的待办对象
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        final originalTodo = _todos[index];

        // 调用API更新
        final updatedTodo = await _todoApi.updateTodo(
            todo.copyWith(
              createdAt: originalTodo.createdAt,
            ),
            category);

        // 更新本地数据
        _todos[index] = updatedTodo;
        await _storage.saveTodos(_todos);
        notifyListeners();
      }
    } catch (e) {
      print('更新待办失败: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      // 先从本地列表中移除
      _todos.removeWhere((todo) => todo.id == id);
      // 通知监听器更新 UI
      notifyListeners();

      // 调用 API 删除待办
      await _todoApi.deleteTodo(id);

      // 更新本地缓存
      await _storage.saveTodos(_todos);
    } catch (e) {
      print('删除待办失败: $e');
      // 如果删除失败，恢复被删除的待办
      await loadTodos();
      rethrow;
    }
  }

  Future<void> toggleTodoStatus(Todo todo, Category? category) async {
    try {
      final newTodo = todo.copyWith(
        completed: !todo.completed,
        updatedAt: DateTime.now(),
      );
      await _todoApi.updateTodo(newTodo, category);

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = newTodo;
        await _storage.saveTodos(_todos);
        notifyListeners();
      }
    } catch (e) {
      print('切换待办状态失败: $e');
      rethrow;
    }
  }

  Future<void> importTodos(List<dynamic> todosData) async {
    _todos.clear();
    _todos.addAll(todosData.map((json) => Todo.fromJson(json)).toList());
    await _storage.saveTodos(_todos);
    notifyListeners();
  }

  Future<Todo> getTodoDetail(int id) async {
    try {
      return await _todoApi.getTodoDetail(id);
    } catch (e) {
      print('获取待办详情失败: $e');
      rethrow;
    }
  }

  // 添加错误处理方法
  void _handleError(String operation, dynamic error) {
    _error = '$operation失败: $error';
    print(_error);
  }

  // 优化离线同步方法
  Future<void> syncOfflineChanges() async {
    if (!_network.hasConnection) return;

    try {
      final pendingCreates = _offlineManager.getPendingChanges('todo_create');
      for (final json in pendingCreates) {
        try {
          final todo = Todo.fromJson(json);
          await _todoApi.createTodo(todo);
        } catch (e) {
          _handleError('同步离线创建', e);
        }
      }
      _offlineManager.clearPendingChanges('todo_create');
      await loadTodos(); // 重新加载数据
    } catch (e) {
      _handleError('同步离线数据', e);
    }
  }

  // 优化过滤方法
  List<Todo> getFilteredTodos(FilterProvider filterProvider) {
    return todos.where((todo) => _matchesFilter(todo, filterProvider)).toList();
  }

  bool _matchesFilter(Todo todo, FilterProvider filter) {
    if (!_matchesSearch(todo, filter.searchQuery)) return false;
    if (!_matchesStatus(todo, filter.filter)) return false;
    if (!_matchesCategory(todo, filter.selectedCategory)) return false;
    if (!_matchesPriority(todo, filter.selectedPriority)) return false;
    return true;
  }

  bool _matchesSearch(Todo todo, String? searchQuery) {
    if (searchQuery == null || searchQuery.isEmpty) return true;
    final query = searchQuery.toLowerCase();
    return todo.title.toLowerCase().contains(query) ||
        (todo.description?.toLowerCase().contains(query) ?? false);
  }

  bool _matchesStatus(Todo todo, TodoFilter? filter) {
    if (filter == null) return true;
    switch (filter) {
      case TodoFilter.active:
        return !todo.completed;
      case TodoFilter.completed:
        return todo.completed;
      default:
        return true;
    }
  }

  bool _matchesCategory(Todo todo, Category? category) {
    if (category == null) return true;
    return todo.categoryId == category.id;
  }

  bool _matchesPriority(Todo todo, String? priority) {
    if (priority == null) return true;
    return todo.priority == priority;
  }

  void beginBatchUpdate() {
    _batchNotify = true;
  }

  void endBatchUpdate() {
    _batchNotify = false;
    if (_pendingUpdates.isNotEmpty) {
      for (final update in _pendingUpdates) {
        update();
      }
      _pendingUpdates.clear();
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (_batchNotify) {
      return;
    }

    if (_lastNotification == null ||
        DateTime.now().difference(_lastNotification!) >
            const Duration(milliseconds: 16)) {
      super.notifyListeners();
      _lastNotification = DateTime.now();
    }
  }
}
