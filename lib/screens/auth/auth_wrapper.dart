import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

/// 认证包装器组件
/// 负责处理应用的认证状态，根据认证状态自动导航到相应页面
/// 未认证时导航到登录页面，已认证时导航到首页
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
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
