import 'package:flutter/material.dart';

import '../../routes/app_router.dart';
import '../../services/storage_service.dart';

/// 认证包装器组件
/// 负责处理应用的认证状态，根据认证状态自动导航到相应页面
/// 未认证时导航到登录页面，已认证时导航到首页
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // 使用缓存优先策略
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        // 显示加载状态
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 使用 WidgetsBinding 来确保在帧结束后执行导航
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final route = snapshot.data ?? AppRouter.login;
          Navigator.pushReplacementNamed(context, route);
        });

        // 返回一个占位的加载界面
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<String?> _getInitialRoute() async {
    final storage = StorageService();
    await storage.init();

    // 先检查内存缓存
    final cachedRoute = storage.getValue<String>('cached_route');
    if (cachedRoute != null) {
      return cachedRoute;
    }

    // 再检查持久化存储
    final token = await storage.getToken();
    final route = token != null ? AppRouter.home : AppRouter.login;

    // 缓存路由结果
    await storage.setValue('cached_route', route);
    return route;
  }
}
