import 'package:dio/dio.dart';
import 'api_client.dart';

class CategoryApi {
  final ApiClient _client;

  CategoryApi(this._client);

  Future<Response> getCategories() {
    return _client.get('/categories');
  }

  Future<Response> createCategory(Map<String, dynamic> data) {
    return _client.post('/categories', data: data);
  }

  Future<Response> updateCategory(int id, Map<String, dynamic> data) {
    return _client.put('/categories/$id', data: data);
  }

  Future<Response> deleteCategory(int id) {
    return _client.delete('/categories/$id');
  }
} 