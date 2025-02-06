import 'package:dio/dio.dart';

import '../services/storage_service.dart';

class ApiClient {
  // 对于 iOS 模拟器，使用特殊的 localhost 地址
  static const String baseUrl = 'http://localhost:8080/api/v1';
  // 或者使用实际的开发机器 IP 地址
  // static const String baseUrl = 'http://192.168.1.xxx:8080/api/v1';
  final Dio _dio;
  final StorageService _storage = StorageService();

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    // 添加默认headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 先清除所有拦截器，以防重复
    _dio.interceptors.clear();

    // 添加自定义拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 对于登录请求，不需要添加 token
        if (!options.path.contains('/auth/login')) {
          try {
            final token = await _storage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            print('【请求拦截器】读取Token时发生错误: $e');
          }
        } else {
          print('【请求拦截器】登录请求，跳过Token验证');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['code'] == 200) {
            // 成功响应，直接返回data字段
            response.data = responseData['data'];
          } else {
            // 业务错误，抛出错误信息
            throw responseData['message'] ?? '未知错误';
          }
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        print('API错误: ${error.message}');
        return handler.next(error);
      },
    ));

    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('【Dio日志】$obj'),
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
