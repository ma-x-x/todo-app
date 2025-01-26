import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // 对于 iOS 模拟器，使用特殊的 localhost 地址
  static const String baseUrl = 'http://localhost:8080/api/v1';
  // 或者使用实际的开发机器 IP 地址
  // static const String baseUrl = 'http://192.168.1.xxx:8080/api/v1';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('Making request to: ${options.uri}');
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        print('Error type: ${error.type}');
        print('Error response: ${error.response}');
        if (error.response?.statusCode == 401) {
          // Handle unauthorized error
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
