import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._();
  factory NetworkService() => _instance;

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _hasConnection = true;

  NetworkService._() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Stream<bool> get onConnectionChange => _controller.stream;
  bool get hasConnection => _hasConnection;

  Future<void> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _hasConnection = result != ConnectivityResult.none;
    _controller.add(_hasConnection);
  }

  void dispose() {
    _controller.close();
  }
}
