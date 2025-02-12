import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'api/category_api.dart';
import 'api/reminder_api.dart';
import 'api/todo_api.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/todo_provider.dart';
import 'routes/app_router.dart';
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

  // 初始化基础服务
  final storage = StorageService();
  await storage.init(); // 确保完成初始化

  final apiClient = ApiClient();
  final notificationService = NotificationService();
  final networkService = NetworkService();
  final offlineManager = OfflineManager();
  final updateService = UpdateService();

  // 创建并初始化通知设置
  final notificationSettings = NotificationSettingsProvider();

  // 创建认证提供者
  final authProvider = AuthProvider(
    apiClient: apiClient,
    storage: storage,
  );

  // 等待所有服务初始化完成
  await Future.wait([
    notificationService.requestPermissions(),
    networkService.checkConnection(),
    offlineManager.init(),
    updateService.init(),
    notificationSettings.loadSettings(),
  ]);

  // 设置通知服务
  notificationService.setSettingsProvider(notificationSettings);

  // 添加性能监控
  if (kDebugMode) {
    debugPrintRebuildDirtyWidgets = true;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message?.contains('rebuild') ?? false) {
        print(message);
      }
    };
  }

  runApp(MultiProvider(
    providers: [
      Provider<StorageService>.value(value: storage),
      Provider<ApiClient>.value(value: apiClient),
      Provider<NotificationService>.value(value: notificationService),
      ChangeNotifierProvider.value(value: authProvider),
      ChangeNotifierProvider(
        create: (_) => TodoProvider(todoApi: TodoApi(apiClient)),
      ),
      ChangeNotifierProvider(
        create: (_) => CategoryProvider(categoryApi: CategoryApi(apiClient)),
      ),
      ChangeNotifierProvider(
        create: (_) => ReminderProvider(reminderApi: ReminderApi(apiClient)),
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
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        return MaterialApp(
          navigatorKey: apiClient.navigatorKey,
          title: 'Todo App',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          onGenerateRoute: AppRouter.generateRoute,
          builder: (context, child) {
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
