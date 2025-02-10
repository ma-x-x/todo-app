import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../services/network_service.dart';
import '../services/storage_service.dart';

class ApiClient {
  late final Dio _dio;

  // 根据是否在调试模式选择不同的基础URL
  static const String _prodBaseUrl = 'http://1.92.74.47:8081/api/v1';
  static const String _devBaseUrl = 'http://172.22.156.37:8080/api/v1';

  final StorageService _storage = StorageService();
  final NetworkService _network = NetworkService();

  final _offlineQueue = <Future<Response> Function()>[];

  ApiClient() {
    const baseUrl = kDebugMode ? _devBaseUrl : _prodBaseUrl;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json',
      responseType: ResponseType.json,
      headers: {
        'Accept-Encoding': 'gzip, deflate',
      },
    ));

    _configureBaseOptions();
    _configureInterceptors();
    _network.onConnectionChange.listen(_handleConnectionChange);
  }

  void _configureBaseOptions() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 添加验证状态码的回调
    _dio.options.validateStatus = (status) {
      print('响应状态码: $status');
      return status != null && status >= 200 && status < 300;
    };
  }

  void _configureInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.addAll([
      _createAuthInterceptor(),
      _createResponseInterceptor(),
      _createLoggingInterceptor(),
      // 添加错误处理拦截器
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // token 失效，清除本地存储的 token
            await _storage.deleteToken();
            // 可以在这里添加重定向到登录页面的逻辑
            if (error.requestOptions.path != '/auth/login') {
              throw DioException(
                requestOptions: error.requestOptions,
                message: '登录已过期，请重新登录',
              );
            }
          }
          return handler.next(error);
        },
      ),
    ]);
  }

  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.path.contains('/auth/login')) {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            // token 不存在，直接抛出认证错误
            throw DioException(
              requestOptions: options,
              message: '请先登录',
            );
          }
        }
        return handler.next(options);
      },
    );
  }

  InterceptorsWrapper _createResponseInterceptor() {
    return InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['code'] == 0 || responseData['code'] == 200) {
            // 成功响应，直接返回data字段
            response.data = responseData['data'];
          } else {
            // 业务错误，抛出错误信息
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: responseData['message'] ?? '未知错误',
            );
          }
        }
        return handler.next(response);
      },
    );
  }

  InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('发送请求: ${options.method} ${options.path}');
        print('请求数据: ${options.data}');
        print('请求头: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('收到响应: ${response.statusCode}');
        print('响应数据: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('API错误: ${error.message}');
        print('错误响应: ${error.response?.data}');
        print('请求数据: ${error.requestOptions.data}');
        print('请求路径: ${error.requestOptions.path}');

        // 如果是服务器错误，尝试提取更有用的错误信息
        if (error.response?.statusCode == 500) {
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic>) {
            final message = responseData['message'] ?? '服务器错误';
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                message: message,
              ),
            );
          }
        }
        return handler.next(error);
      },
    );
  }

  Future<void> _handleConnectionChange(bool hasConnection) async {
    if (hasConnection && _offlineQueue.isNotEmpty) {
      print('网络已恢复，处理离线队列...');
      final queue = List<Future<Response> Function()>.from(_offlineQueue);
      _offlineQueue.clear();

      for (final request in queue) {
        try {
          await request();
        } catch (e) {
          print('处理离线请求失败: $e');
        }
      }
    }
  }

  Future<Response> _executeWithOfflineSupport(
    Future<Response> Function() request,
    bool canQueue,
  ) async {
    try {
      return await request();
    } catch (e) {
      if (e is DioException && !_network.hasConnection) {
        if (canQueue) {
          print('网络离线，将请求加入队列');
          _offlineQueue.add(request);
        }
        throw const OfflineException('当前处于离线模式');
      }
      rethrow;
    }
  }

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _executeWithOfflineSupport(
      () => _dio.get(path, queryParameters: queryParameters),
      false,
    );
  }

  @override
  Future<Response> post(String path, {dynamic data}) {
    return _executeWithOfflineSupport(
      () => _dio.post(path, data: data),
      true,
    );
  }

  @override
  Future<Response> put(String path, {dynamic data}) {
    return _executeWithOfflineSupport(
      () => _dio.put(path, data: data),
      true,
    );
  }

  @override
  Future<Response> delete(String path) {
    return _executeWithOfflineSupport(
      () => _dio.delete(path),
      true,
    );
  }

  // 添加重试机制
  Future<Response> _retryRequest(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        // 重试请求
        return await request();
      }
      rethrow;
    }
  }

  // 添加请求缓存
  final _cache = <String, CachedResponse>{};

  Future<Response> getCached(String path, {Duration? maxAge}) async {
    final cacheKey = path;
    final cached = _cache[cacheKey];

    if (cached != null && !cached.isExpired(maxAge)) {
      return cached.response;
    }

    final response = await get(path);
    _cache[cacheKey] = CachedResponse(response);
    return response;
  }
}

class CachedResponse {
  final Response response;
  final DateTime timestamp;

  CachedResponse(this.response) : timestamp = DateTime.now();

  bool isExpired(Duration? maxAge) {
    if (maxAge == null) return true;
    return DateTime.now().difference(timestamp) > maxAge;
  }
}

class OfflineException implements Exception {
  final String message;
  const OfflineException(this.message);

  @override
  String toString() => message;
}
