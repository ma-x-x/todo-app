import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../category/category_list_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';
import '../todo/todo_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;

  // 使用 PageStorageBucket 来保存页面状态
  final PageStorageBucket _bucket = PageStorageBucket();

  // 懒加载页面
  late final List<Widget> _pages = [
    const TodoListScreen(key: PageStorageKey('todos')),
    const CategoryListScreen(key: PageStorageKey('categories')),
    const StatisticsScreen(key: PageStorageKey('statistics')),
    const SettingsScreen(key: PageStorageKey('settings')),
  ];

  // 保持页面状态
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // 使用 PageStorage 保存页面状态
      body: PageStorage(
        bucket: _bucket,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // 始终显示标签
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            label: AppLocalizations.of(context)!.todos,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            label: AppLocalizations.of(context)!.categories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            label: AppLocalizations.of(context)!.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
