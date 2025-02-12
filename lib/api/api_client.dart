import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/network_service.dart';
import '../services/storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final navigatorKey = GlobalKey<NavigatorState>();

  // 生产环境和开发环境的API基础URL
  static const String _prodBaseUrl = 'http://1.92.74.47:8081/api/v1';
  static const String _devBaseUrl = 'http://localhost:8080/api/v1';

  // 存储服务，用于管理token等本地存储数据
  final StorageService _storage = StorageService();
  // 网络服务，用于监控网络状态
  final NetworkService _network = NetworkService();

  // 离线请求队列，存储在离线状态下的请求
  final _offlineQueue = <Future<Response> Function()>[];

  CancelToken? _cancelToken;

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
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
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
  }

  void _configureInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onError: (error, handler) async {
          print('Error interceptor: ${error.response?.statusCode}');
          if (error.response?.statusCode == 401) {
            try {
              await _storage.deleteToken();
              await _storage.deleteUser();

              final context = navigatorKey.currentContext;
              if (context != null && context.mounted) {
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();

                Future.microtask(() {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                });
              }
            } catch (e) {
              print('Error handling 401: $e');
            }
          }
          return handler.next(error);
        },
      ),
      _createAuthInterceptor(),
      _createResponseInterceptor(),
      _createLoggingInterceptor(),
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
            response.data = responseData['data'];
            return handler.next(response);
          } else {
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              message: responseData['message'] ?? '未知错误',
            );
          }
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.data is Map<String, dynamic>) {
          final responseData = error.response!.data as Map<String, dynamic>;
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              message: responseData['message'] ?? error.message,
            ),
          );
        }
        return handler.next(error);
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

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _executeWithOfflineSupport(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? _cancelToken,
      ),
      false,
    );
  }

  Future<Response> post(String path, {dynamic data}) {
    return _executeWithOfflineSupport(
      () => _dio.post(path, data: data),
      true,
    );
  }

  Future<Response> put(String path, {dynamic data}) {
    return _executeWithOfflineSupport(
      () => _dio.put(path, data: data),
      true,
    );
  }

  Future<Response> delete(String path) {
    return _executeWithOfflineSupport(
      () => _dio.delete(path),
      true,
    );
  }

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

  void clearAuth() {
    _dio.interceptors.clear();
    _configureInterceptors();
  }

  void cancelRequests({String? reason}) {
    _cancelToken?.cancel(reason);
    _cancelToken = CancelToken();
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
