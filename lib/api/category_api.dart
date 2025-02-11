import '../api/api_client.dart';
import '../models/category.dart';

class CategoryApi {
  final ApiClient _client;

  CategoryApi(this._client);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get('/categories');
      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('items') || data['items'] is! List) {
        throw '响应数据格式错误';
      }

      return (data['items'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      print('获取分类列表失败: $e');
      rethrow;
    }
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/categories', data: data);
      return Category.fromJson(response.data);
    } catch (e) {
      print('创建分类失败: $e');
      rethrow;
    }
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/categories/$id', data: data);
      return Category.fromJson(response.data);
    } catch (e) {
      print('更新分类失败: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _client.delete('/categories/$id');
    } catch (e) {
      print('删除分类失败: $e');
      rethrow;
    }
  }
}
