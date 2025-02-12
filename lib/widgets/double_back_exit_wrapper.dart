import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackExitWrapper extends StatefulWidget {
  final Widget child;
  final String exitMessage;

  const DoubleBackExitWrapper({
    required this.child,
    this.exitMessage = '再按一次退出应用',
    super.key,
  });

  @override
  State<DoubleBackExitWrapper> createState() => _DoubleBackExitWrapperState();
}

class _DoubleBackExitWrapperState extends State<DoubleBackExitWrapper> {
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_onBackPressed);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_onBackPressed);
    super.dispose();
  }

  bool _onBackPressed(bool stopDefaultButtonEvent, RouteInfo info) {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.exitMessage),
          duration: const Duration(seconds: 2),
        ),
      );
      return true; // 拦截返回事件
    }
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
