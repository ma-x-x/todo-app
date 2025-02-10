import '../models/todo.dart';
import 'api_client.dart';

class TodoApi {
  final ApiClient _apiClient;

  TodoApi(this._apiClient);

  Future<List<Todo>> getTodos() async {
    try {
      final response = await _apiClient.get('/todos');

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw '无效的响应格式';
      }

      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('items') || data['items'] is! List) {
        throw '响应数据缺少items字段或格式错误';
      }

      return (data['items'] as List)
          .map((json) => Todo.fromJson(json))
          .toList();
    } catch (e) {
      print('获取待办事项失败: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _apiClient.delete('/todos/$id');
    } catch (e) {
      print('删除待办失败: $e');
      rethrow;
    }
  }

  Future<Todo> createTodo(Todo todo) async {
    try {
      final response = await _apiClient.post('/todos', data: todo.toJson());
      return Todo.fromJson(response.data);
    } catch (e) {
      print('创建待办失败: $e');
      rethrow;
    }
  }

  Future<Todo> updateTodo(Todo todo) async {
    try {
      await _apiClient.put('/todos/${todo.id}', data: todo.toJson());

      // 后端只返回成功状态，直接返回传入的todo对象，保留所有原有信息
      return todo.copyWith(
        category: todo.category, // 确保保留分类信息
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('更新待办失败: $e');
      rethrow;
    }
  }

  Future<Todo> getTodoDetail(int id) async {
    try {
      final response = await _apiClient.get('/todos/$id');
      return Todo.fromJson(response.data);
    } catch (e) {
      print('获取待办详情失败: $e');
      rethrow;
    }
  }
}
