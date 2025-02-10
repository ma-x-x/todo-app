class ErrorReportingService {
  static final ErrorReportingService _instance = ErrorReportingService._();
  factory ErrorReportingService() => _instance;

  ErrorReportingService._();

  Future<void> reportError(dynamic error, StackTrace stackTrace) async {
    // 实现错误上报逻辑
    // 例如发送到 Sentry、Firebase Crashlytics 等
    print('Reporting error: $error');
    print('Stack trace: $stackTrace');
  }
}
