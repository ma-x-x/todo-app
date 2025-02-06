import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../services/storage_service.dart';

class NotificationSettingsProvider with ChangeNotifier {
  final _storage = StorageService();

  bool _enabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  // Getters
  bool get enabled => _enabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get quietHoursEnabled => _quietHoursEnabled;
  TimeOfDay get quietHoursStart => _quietHoursStart;
  TimeOfDay get quietHoursEnd => _quietHoursEnd;

  // 加载设置
  Future<void> loadSettings() async {
    _enabled = _storage.getValue<bool>('notification_enabled') ?? true;
    _soundEnabled = _storage.getValue<bool>('notification_sound') ?? true;
    _vibrationEnabled =
        _storage.getValue<bool>('notification_vibration') ?? true;
    _quietHoursEnabled =
        _storage.getValue<bool>('notification_quiet_hours') ?? false;

    final startHour = _storage.getValue<int>('notification_quiet_start_hour');
    final startMinute =
        _storage.getValue<int>('notification_quiet_start_minute');
    if (startHour != null && startMinute != null) {
      _quietHoursStart = TimeOfDay(hour: startHour, minute: startMinute);
    }

    final endHour = _storage.getValue<int>('notification_quiet_end_hour');
    final endMinute = _storage.getValue<int>('notification_quiet_end_minute');
    if (endHour != null && endMinute != null) {
      _quietHoursEnd = TimeOfDay(hour: endHour, minute: endMinute);
    }

    notifyListeners();
  }

  // Setters
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await _storage.setValue('notification_enabled', value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _storage.setValue('notification_sound', value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _storage.setValue('notification_vibration', value);
    notifyListeners();
  }

  Future<void> setQuietHoursEnabled(bool value) async {
    _quietHoursEnabled = value;
    await _storage.setValue('notification_quiet_hours', value);
    notifyListeners();
  }

  Future<void> setQuietHoursStart(TimeOfDay time) async {
    _quietHoursStart = time;
    await _storage.setValue('notification_quiet_start_hour', time.hour);
    await _storage.setValue('notification_quiet_start_minute', time.minute);
    notifyListeners();
  }

  Future<void> setQuietHoursEnd(TimeOfDay time) async {
    _quietHoursEnd = time;
    await _storage.setValue('notification_quiet_end_hour', time.hour);
    await _storage.setValue('notification_quiet_end_minute', time.minute);
    notifyListeners();
  }

  bool isQuietTime() {
    if (!_quietHoursEnabled) return false;

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = _quietHoursStart.hour * 60 + _quietHoursStart.minute;
    final endMinutes = _quietHoursEnd.hour * 60 + _quietHoursEnd.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // 处理跨天的情况
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}
