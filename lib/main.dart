import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 配置 lifecycle channel 的缓冲区
  ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(
    "flutter/lifecycle",
    (ByteData? message) async {
      return null;
    },
  );

  // 初始化存储服务
  final storage = StorageService();
  await storage.init();

  // 创建认证提供者并加载存储的认证状态
  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();

  // 创建通知设置提供者
  final notificationSettings = NotificationSettingsProvider();
  // 加载通知设置
  await notificationSettings.loadSettings();

  // 设置到通知服务
  NotificationService().setSettingsProvider(notificationSettings);

  // 使用 runApp 之前进行必要的初始化
  await Future.wait([
    NotificationService().requestPermissions(),
    // 其他需要异步初始化的服务...
  ]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: authProvider),
      ChangeNotifierProvider(
        lazy: true,
        create: (_) => TodoProvider(),
      ),
      ChangeNotifierProvider(
        lazy: true,
        create: (_) => CategoryProvider(),
      ),
      ChangeNotifierProvider(
        lazy: true,
        create: (_) => ReminderProvider(),
      ),
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
          navigatorObservers: [
            _AuthRouteObserver(),
          ],
          onGenerateRoute: (settings) {
            // 处理根路由
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (_) => context.read<AuthProvider>().isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen(),
              );
            }
            // 处理其他路由
            return AppRouter.generateRoute(settings);
          },
          initialRoute: '/',
        );
      },
    );
  }
}

// 添加路由观察者类
class _AuthRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _checkAuth(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _checkAuth(newRoute);
    }
  }

  void _checkAuth(Route<dynamic> route) {
    // 获取当前路由名称
    final routeName = route.settings.name;
    if (routeName == null) return;

    // 如果不是登录或注册页面，检查认证状态
    if (routeName != AppRouter.login && routeName != AppRouter.register) {
      Future.delayed(Duration.zero, () {
        final context = navigator?.context;
        if (context != null && !context.read<AuthProvider>().isAuthenticated) {
          navigator?.pushNamedAndRemoveUntil(
            AppRouter.login,
            (route) => false,
          );
        }
      });
    }
  }
}
