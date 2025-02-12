import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, [dynamic result]) async {
        if (didPop) return;

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
          return;
        }
        return;
      },
      child: widget.child,
    );
  }
}
