import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../todo/todo_list_screen.dart';
import '../category/category_list_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pages = const [
    TodoListScreen(),
    CategoryListScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
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