import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/todo_api.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';

class TodoProvider with ChangeNotifier {
  final TodoApi _todoApi;
  final StorageService _storage = StorageService();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  TodoProvider() : _todoApi = TodoApi(ApiClient()) {
    loadTodos();
  }

  void _loadCachedTodos() {
    final cachedTodos = _storage.getTodos();
    if (cachedTodos != null) {
      _todos = cachedTodos;
      notifyListeners();
    }
  }

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('开始加载待办事项...');
      _todos = await _todoApi.getTodos();
      // 缓存数据
      await _storage.saveTodos(_todos);
      print('成功加载待办事项: ${_todos.length}个项目');
      notifyListeners();
    } catch (e) {
      print('加载待办事项失败: $e');
      _error = e.toString();
      // 如果网络请求失败，尝试使用缓存数据
      _loadCachedTodos();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTodo(Todo todo) async {
    try {
      final response = await _todoApi.createTodo(todo);
      _todos.add(response);
      await _storage.saveTodos(_todos);
      notifyListeners();
    } catch (e) {
      print('创建待办失败: $e');
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      // 保存原有的待办对象
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        final originalTodo = _todos[index];

        // 调用API更新
        final updatedTodo = await _todoApi.updateTodo(todo.copyWith(
          createdAt: originalTodo.createdAt,
        ));

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

  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final updatedTodo = await _todoApi.updateTodo(todo.copyWith(
        completed: !todo.completed,
        updatedAt: DateTime.now(),
      ));

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        await _storage.saveTodos(_todos);
        notifyListeners();
      }
    } catch (e) {
      print('切换待办状态失败: $e');
      rethrow;
    }
  }

  Future<void> importTodos(List<dynamic> todosData) async {
    _todos = todosData.map((json) => Todo.fromJson(json)).toList();
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
}
