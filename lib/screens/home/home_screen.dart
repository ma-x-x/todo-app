import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../category/category_list_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';
import '../todo/todo_list_screen.dart';

/// 应用主页面
/// 包含待办事项、分类、统计和设置四个主要功能模块
/// 使用底部导航栏进行切换，并保持各页面状态
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 当前选中的底部导航项索引
  int _currentIndex = 0;

  /// 懒加载的页面列表
  late final List<Widget> _pages = [
    const TodoListScreen(),
    const CategoryListScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _pages[_currentIndex],
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
          onDestinationSelected: _onTabChanged,
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
