import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../l10n/l10n.dart';

class LocaleProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  Locale? _locale;

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

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    await _storage.saveLocale(locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    _storage.saveLocale('');
    notifyListeners();
  }
} 