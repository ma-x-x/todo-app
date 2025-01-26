import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';

class TodoProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  TodoProvider() {
    _loadCachedTodos();
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

  Future<void> fetchTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/todos');
      final List<dynamic> data = response.data['items'];
      _todos = data.map((json) => Todo.fromJson(json)).toList();
      
      // 缓存数据
      await _storage.saveTodos(_todos);
      
      notifyListeners();
    } catch (e) {
      _error = '获取待办事项失败：${e.toString()}';
      print(_error);
      // 如果网络请求失败，尝试使用缓存数据
      _loadCachedTodos();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTodo(Todo todo) async {
    try {
      final response = await _apiClient.post('/todos', data: todo.toJson());
      final newTodo = Todo.fromJson(response.data['todo']);
      _todos.add(newTodo);
      notifyListeners();
    } catch (e) {
      print('Error creating todo: $e');
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _apiClient.put('/todos/${todo.id}', data: todo.toJson());
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _apiClient.delete('/todos/$id');
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        completed: !todo.completed,
        priority: todo.priority,
        categoryId: todo.categoryId,
        createdAt: todo.createdAt,
        updatedAt: DateTime.now(),
      );

      await _apiClient.put('/todos/${todo.id}', 
        data: {'completed': !todo.completed}
      );
      
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling todo status: $e');
      rethrow;
    }
  }

  Future<void> importTodos(List<dynamic> todosData) async {
    _todos = todosData.map((json) => Todo.fromJson(json)).toList();
    await _storage.saveTodos(_todos);
    notifyListeners();
  }
} 