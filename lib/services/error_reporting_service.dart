/// 错误报告服务类
/// 负责收集和上报应用程序错误信息
class ErrorReportingService {
  // 单例模式实现
  static final ErrorReportingService _instance = ErrorReportingService._();
  factory ErrorReportingService() => _instance;

  ErrorReportingService._();

  /// 上报错误信息
  ///
  /// 参数:
  /// - error: 错误对象
  /// - stackTrace: 错误堆栈跟踪
  ///
  /// 可以集成第三方错误追踪服务，如 Sentry 或 Firebase Crashlytics
  Future<void> reportError(dynamic error, StackTrace stackTrace) async {
    // 实现错误上报逻辑
    // 例如发送到 Sentry、Firebase Crashlytics 等
    print('Reporting error: $error');
    print('Stack trace: $stackTrace');
  }
}
