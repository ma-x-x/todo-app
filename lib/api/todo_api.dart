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
      final response =
          await _apiClient.put('/todos/${todo.id}', data: todo.toJson());
      return Todo.fromJson(response.data);
    } catch (e) {
      print('更新待办失败: $e');
      rethrow;
    }
  }
}
