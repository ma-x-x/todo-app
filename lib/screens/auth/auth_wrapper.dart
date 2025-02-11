import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        print('AuthWrapper rebuild:');
        print('- isAuthenticated: ${auth.isAuthenticated}');
        print('- currentUser: ${auth.currentUser}');
        print('- isLoading: ${auth.isLoading}');

        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 使用导航而不是条件渲染
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (auth.isAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });

        // 返回一个加载页面作为过渡
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
