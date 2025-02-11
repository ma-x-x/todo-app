import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../utils/theme.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  ThemeMode _themeMode = ThemeMode.system;

  // 添加主题模式常量
  static const defaultThemeMode = ThemeMode.system;

  ThemeProvider() : _themeMode = ThemeMode.system {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  // 添加主题模式验证方法
  bool _isValidThemeMode(String? themeModeStr) {
    return ThemeMode.values.any((mode) => mode.toString() == themeModeStr);
  }

  // 优化主题加载方法
  void _loadThemeMode() {
    final savedTheme = _storage.getThemeMode();
    if (_isValidThemeMode(savedTheme)) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => defaultThemeMode,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(mode.toString());
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // 添加主题切换方法
  Future<void> toggleThemeMode() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // 添加主题重置方法
  Future<void> resetThemeMode() async {
    await setThemeMode(defaultThemeMode);
  }
}
