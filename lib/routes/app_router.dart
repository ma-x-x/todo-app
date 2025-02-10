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

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String todoForm = '/todo/form';
  static const String categories = '/categories';
  static const String categoryForm = '/category/form';
  static const String reminders = '/reminders';
  static const String reminderForm = '/reminder/form';
  static const String settingsRoute = '/settings';
  static const String themeSettings = '/settings/theme';
  static const String notificationSettings = '/settings/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        return MaterialPageRoute(
          builder: (_) => WillPopScope(
            onWillPop: () async {
              final DateTime now = DateTime.now();
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
                return false;
              }
              return true;
            },
            child: const HomeScreen(),
          ),
        );

      case todoForm:
        final todo = settings.arguments as Todo?;
        return MaterialPageRoute(
          builder: (_) => TodoFormScreen(todo: todo),
        );

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoryListScreen());

      case categoryForm:
        final category = settings.arguments as Category?;
        return MaterialPageRoute(
          builder: (_) => CategoryFormScreen(category: category),
        );

      case reminders:
        final todo = settings.arguments as Todo;
        return MaterialPageRoute(
          builder: (_) => ReminderListScreen(todo: todo),
        );

      case reminderForm:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReminderFormScreen(
            todoId: args['todoId'] as int,
            todoTitle: args['todoTitle'] as String,
            reminder: args['reminder'] as Reminder?,
          ),
        );

      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case themeSettings:
        return MaterialPageRoute(builder: (_) => const ThemeSettingsScreen());

      case notificationSettings:
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static DateTime? _lastPressedAt;
}
