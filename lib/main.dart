import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/l10n.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/todo_provider.dart';
import 'routes/app_router.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化存储服务
  await StorageService().init();

  // 创建认证提供者并加载存储的认证状态
  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();

  // 创建通知设置提供者
  final notificationSettings = NotificationSettingsProvider();
  // 加载通知设置
  await notificationSettings.loadSettings();

  // 设置到通知服务
  NotificationService().setSettingsProvider(notificationSettings);
  // 请求通知权限
  await NotificationService().requestPermissions();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: authProvider),
      ChangeNotifierProvider(create: (_) => TodoProvider()),
      ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => FilterProvider()),
      ChangeNotifierProvider.value(value: notificationSettings),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'Todo App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          supportedLocales: L10n.all,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: context.watch<AuthProvider>().isAuthenticated
              ? AppRouter.home
              : AppRouter.login,
        );
      },
    );
  }
}
