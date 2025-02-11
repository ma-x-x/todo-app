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
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: PageStorage(
          bucket: _bucket,
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          backgroundColor: theme.colorScheme.surface,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          indicatorColor: theme.colorScheme.secondaryContainer,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline,
                  color: _currentIndex == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant),
              label: AppLocalizations.of(context)!.todos,
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined,
                  color: _currentIndex == 1
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant),
              label: AppLocalizations.of(context)!.categories,
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined,
                  color: _currentIndex == 2
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant),
              label: AppLocalizations.of(context)!.statistics,
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined,
                  color: _currentIndex == 3
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant),
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
        ),
      ),
    );
  }
}
