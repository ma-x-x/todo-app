import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../utils/theme.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() : _themeMode = ThemeMode.system {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  void _loadThemeMode() {
    final savedTheme = _storage.getThemeMode();
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
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
}
