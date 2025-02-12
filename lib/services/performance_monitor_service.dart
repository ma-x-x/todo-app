import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceMonitorService {
  static void initialize() {
    if (kDebugMode) {
      debugPrintRebuildDirtyWidgets = true;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message?.contains('rebuild') ?? false) {
          print(message);
        }
      };
    }
  }
}
