import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

abstract class ApiBase {
  final logger = Logger();

  Future<T> handleApiCall<T>(
      String operation, Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      logger.e('$operation failed: ${e.message}',
          error: e, stackTrace: e.stackTrace);
      throw _mapDioError(e);
    } catch (e, stackTrace) {
      logger.e('$operation failed: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Exception _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('连接超时，请检查网络');
      case DioExceptionType.badResponse:
        return ApiException(e.response?.statusCode ?? 500, e.message ?? '请求失败');
      default:
        return ApiException(500, e.message ?? '未知错误');
    }
  }
}

class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => 'ApiException: [$code] $message';
}
