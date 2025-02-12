import '../api/api_client.dart';
import '../models/category.dart';
import '../models/todo.dart';
import 'api_base.dart';

class TodoApi extends ApiBase {
  final ApiClient _client;

  TodoApi(this._client);

  Future<List<Todo>> getTodos() async {
    return handleApiCall('getTodos', () async {
      final response = await _client.get('/todos');
      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('items') || data['items'] is! List) {
        throw ApiException(500, '响应数据格式错误');
      }

      return (data['items'] as List)
          .map((json) => Todo.fromJson(json))
          .toList();
    });
  }

  Future<Todo> getTodoDetail(int id) async {
    return handleApiCall('getTodoDetail', () async {
      final response = await _client.get('/todos/$id');
      return Todo.fromJson(response.data);
    });
  }

  Future<Todo> createTodo(Todo todo) async {
    return handleApiCall('createTodo', () async {
      final response = await _client.post(
        '/todos',
        data: todo.toJson(),
      );
      return Todo.fromJson(response.data);
    });
  }

  Future<Todo> updateTodo(Todo todo, Category? category) async {
    return handleApiCall('updateTodo', () async {
      await _client.put(
        '/todos/${todo.id}',
        data: todo.toJson(),
      );
      return Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        categoryId: todo.categoryId,
        priority: todo.priority,
        createdAt: todo.createdAt,
        updatedAt: todo.updatedAt,
        category: category,
      );
    });
  }

  Future<void> deleteTodo(int id) async {
    return handleApiCall('deleteTodo', () async {
      await _client.delete('/todos/$id');
    });
  }
}
