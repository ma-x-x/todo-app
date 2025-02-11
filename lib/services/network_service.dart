import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络服务类
/// 监控网络连接状态，提供网络状态变化的通知
class NetworkService {
  // 单例模式实现
  static final NetworkService _instance = NetworkService._();
  factory NetworkService() => _instance;

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _hasConnection = true;

  NetworkService._() {
    // 监听网络状态变化
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// 网络状态变化流
  Stream<bool> get onConnectionChange => _controller.stream;

  /// 当前是否有网络连接
  bool get hasConnection => _hasConnection;

  /// 检查当前网络连接状态
  Future<void> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  /// 更新网络连接状态
  ///
  /// 参数:
  /// - result: 连接状态结果
  void _updateConnectionStatus(ConnectivityResult result) {
    _hasConnection = result != ConnectivityResult.none;
    _controller.add(_hasConnection);
  }

  /// 释放资源
  void dispose() {
    _controller.close();
  }
}
