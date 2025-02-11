import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/storage_service.dart';

class LocaleProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  Locale? _locale;

  // 添加默认语言常量
  static const defaultLocale = Locale('zh', 'CN');

  LocaleProvider() {
    _loadLocale();
  }

  Locale? get locale => _locale;

  void _loadLocale() {
    final savedLocale = _storage.getLocale();
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  // 添加语言验证方法
  bool _isValidLocale(Locale locale) {
    return L10n.all.contains(locale);
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isValidLocale(locale)) {
      print('不支持的语言: ${locale.languageCode}');
      return;
    }

    _locale = locale;
    await _storage.saveLocale(locale.languageCode);
    notifyListeners();
  }

  // 添加重置语言方法
  Future<void> resetToSystemLocale() async {
    clearLocale();
    final systemLocale = WidgetsBinding.instance.window.locale;
    if (_isValidLocale(systemLocale)) {
      await setLocale(systemLocale);
    } else {
      await setLocale(defaultLocale);
    }
  }

  void clearLocale() {
    _locale = null;
    _storage.saveLocale('');
    notifyListeners();
  }
}
