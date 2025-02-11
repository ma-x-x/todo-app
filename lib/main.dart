import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/todo_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/network_service.dart';
import 'services/notification_service.dart';
import 'services/offline_manager.dart';
import 'services/storage_service.dart';
import 'services/update_service.dart';
import 'widgets/error_boundary.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置全局错误处理
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              details.exception.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  };

  // 配置 lifecycle channel 的缓冲区
  ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(
    "flutter/lifecycle",
    (ByteData? message) async {
      return null;
    },
  );

  // 初始化服务
  final storage = StorageService();
  await storage.init();
  final apiClient = ApiClient();
  final notificationService = NotificationService();

  // 创建认证提供者
  final authProvider = AuthProvider(
    apiClient: apiClient,
    storage: storage,
  );

  // 创建通知设置提供者
  final notificationSettings = NotificationSettingsProvider();
  // 加载通知设置
  await notificationSettings.loadSettings();

  // 设置到通知服务
  notificationService.setSettingsProvider(notificationSettings);

  // 初始化离线支持
  final networkService = NetworkService();
  await networkService.checkConnection();

  final offlineManager = OfflineManager();
  await offlineManager.init();

  // 初始化更新服务
  final updateService = UpdateService();
  await updateService.init();

  // 使用 runApp 之前进行必要的初始化
  await Future.wait([
    notificationService.requestPermissions(),
    // 其他需要异步初始化的服务...
  ]);

  runApp(MultiProvider(
    providers: [
      Provider<StorageService>.value(value: storage),
      Provider<ApiClient>.value(value: apiClient),
      Provider<NotificationService>.value(value: notificationService),
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
      Provider<NetworkService>.value(value: networkService),
      Provider<UpdateService>.value(value: updateService),
    ],
    child: const ErrorBoundary(
      child: MyApp(),
    ),
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
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
