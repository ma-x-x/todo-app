import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
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
import 'services/network_service.dart';
import 'services/notification_service.dart';
import 'services/offline_manager.dart';
import 'services/storage_service.dart';
import 'services/update_service.dart';
import 'utils/theme.dart';
import 'widgets/error_boundary.dart';
import 'widgets/update_dialog.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final updateService = context.read<UpdateService>();
    final updateInfo = await updateService.checkForUpdates();

    if (updateInfo != null && mounted) {
      // 显示更新对话框
      await showDialog(
        context: context,
        barrierDismissible: !updateInfo.isForced,
        builder: (context) => UpdateDialog(updateInfo: updateInfo),
      );
    }
  }

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
