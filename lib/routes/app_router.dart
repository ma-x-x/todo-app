import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/reminder.dart';
import '../models/todo.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/category/category_form_screen.dart';
import '../screens/category/category_list_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/reminder/reminder_form_screen.dart';
import '../screens/reminder/reminder_list_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/theme_settings_screen.dart';
import '../screens/todo/todo_form_screen.dart';

/// 应用路由管理器
/// 负责管理应用内所有页面的路由跳转
class AppRouter {
  /// 登录页面路由
  static const String login = '/login';

  /// 注册页面路由
  static const String register = '/register';

  /// 首页路由
  static const String home = '/home';

  /// 待办事项表单页面路由
  static const String todoForm = '/todo/form';

  /// 分类列表页面路由
  static const String categories = '/categories';

  /// 分类表单页面路由
  static const String categoryForm = '/category/form';

  /// 提醒列表页面路由
  static const String reminders = '/reminders';

  /// 提醒表单页面路由
  static const String reminderForm = '/reminder/form';

  /// 设置页面路由
  static const String settingsRoute = '/settings';

  /// 主题设置页面路由
  static const String themeSettings = '/settings/theme';

  /// 通知设置页面路由
  static const String notificationSettings = '/settings/notifications';

  /// 路由生成器
  /// 根据路由名称和参数生成对应的页面路由
  /// [settings] 包含路由名称和参数
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        // 首页添加双击退出应用的功能
        return MaterialPageRoute(
          builder: (_) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, [dynamic result]) async {
              if (didPop) return;

              final DateTime now = DateTime.now();
              // 判断是否在2秒内连续点击返回键
              if (_lastPressedAt == null ||
                  now.difference(_lastPressedAt!) >
                      const Duration(seconds: 2)) {
                _lastPressedAt = now;
                ScaffoldMessenger.of(_).showSnackBar(
                  const SnackBar(
                    content: Text('再按一次退出应用'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return; // 阻止返回操作
              } else {
                // 允许返回操作
                return;
              }
            },
            child: const HomeScreen(),
          ),
        );

      case todoForm:
        // 待办事项表单页面，支持新建和编辑模式
        final todo = settings.arguments as Todo?;
        return MaterialPageRoute(
          builder: (_) => TodoFormScreen(todo: todo),
        );

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoryListScreen());

      case categoryForm:
        // 分类表单页面，支持新建和编辑模式
        final category = settings.arguments as Category?;
        return MaterialPageRoute(
          builder: (_) => CategoryFormScreen(category: category),
        );

      case reminders:
        // 提醒列表页面，显示指定待办事项的所有提醒
        final todo = settings.arguments as Todo;
        return MaterialPageRoute(
          builder: (_) => ReminderListScreen(todo: todo),
        );

      case reminderForm:
        // 提醒表单页面，支持新建和编辑模式
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReminderFormScreen(
            todoId: args['todoId'] as int,
            todoTitle: args['todoTitle'] as String,
            reminder: args['reminder'] as Reminder?,
          ),
        );

      case themeSettings:
        return MaterialPageRoute(
          builder: (_) => const ThemeSettingsScreen(),
        );

      case notificationSettings:
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsScreen(),
        );

      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      default:
        // 处理未定义的路由
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('未知路由: ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// 记录上次点击返回键的时间
  /// 用于实现双击退出应用的功能
  static DateTime? _lastPressedAt;
}
