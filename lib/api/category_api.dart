import '../models/category.dart';
import 'api_client.dart';

class CategoryApi {
  final ApiClient _apiClient;

  CategoryApi(this._apiClient);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      return (response.data['items'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      print('获取分类失败: $e');
      rethrow;
    }
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/categories', data: {
        'name': data['name'],
        'color': data['color'],
      });
      return Category.fromJson({
        'id': response.data['id'],
        'name': data['name'],
        'color': data['color'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('创建分类失败: $e');
      rethrow;
    }
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/categories/$id', data: data);
      return Category.fromJson(response.data);
    } catch (e) {
      print('更新分类失败: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _apiClient.delete('/categories/$id');
    } catch (e) {
      print('删除分类失败: $e');
      rethrow;
    }
  }
}
