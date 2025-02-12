import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final _instance = PerformanceMonitor._();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._();

  void logBuildTime(String widgetName, Duration duration) {
    if (kDebugMode && duration.inMilliseconds > 16) {
      print('$widgetName build took ${duration.inMilliseconds}ms');
    }
  }
}
