import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../services/storage_service.dart';

/// 通知设置状态管理器
/// 管理应用的通知相关设置，包括：
/// - 通知开关
/// - 声音开关
/// - 振动开关
/// - 免打扰时间
class NotificationSettingsProvider with ChangeNotifier {
  final _storage = StorageService();
  String? _error;

  // 通知相关状态
  bool _enabled = true; // 通知总开关
  bool _soundEnabled = true; // 声音开关
  bool _vibrationEnabled = true; // 振动开关
  bool _quietHoursEnabled = false; // 免打扰时间开关
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0); // 免打扰开始时间
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0); // 免打扰结束时间

  // Getters
  bool get enabled => _enabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get quietHoursEnabled => _quietHoursEnabled;
  TimeOfDay get quietHoursStart => _quietHoursStart;
  TimeOfDay get quietHoursEnd => _quietHoursEnd;

  /// 添加缓存键常量，避免字符串硬编码
  static const String _KEY_ENABLED = 'notification_enabled';
  static const String _KEY_SOUND = 'notification_sound';
  static const String _KEY_VIBRATION = 'notification_vibration';
  static const String _KEY_QUIET_HOURS = 'notification_quiet_hours';
  static const String _KEY_QUIET_START_HOUR = 'notification_quiet_start_hour';
  static const String _KEY_QUIET_START_MINUTE =
      'notification_quiet_start_minute';
  static const String _KEY_QUIET_END_HOUR = 'notification_quiet_end_hour';
  static const String _KEY_QUIET_END_MINUTE = 'notification_quiet_end_minute';

  String? get error => _error;

  /// 加载存储的通知设置
  /// 从本地存储加载所有通知相关的设置，如果没有存储过则使用默认值
  Future<void> loadSettings() async {
    try {
      _enabled = _storage.getValue<bool>(_KEY_ENABLED) ?? true;
      _soundEnabled = _storage.getValue<bool>(_KEY_SOUND) ?? true;
      _vibrationEnabled = _storage.getValue<bool>(_KEY_VIBRATION) ?? true;
      _quietHoursEnabled = _storage.getValue<bool>(_KEY_QUIET_HOURS) ?? false;

      final startHour = _storage.getValue<int>(_KEY_QUIET_START_HOUR);
      final startMinute = _storage.getValue<int>(_KEY_QUIET_START_MINUTE);
      if (startHour != null && startMinute != null) {
        _quietHoursStart = TimeOfDay(hour: startHour, minute: startMinute);
      }

      final endHour = _storage.getValue<int>(_KEY_QUIET_END_HOUR);
      final endMinute = _storage.getValue<int>(_KEY_QUIET_END_MINUTE);
      if (endHour != null && endMinute != null) {
        _quietHoursEnd = TimeOfDay(hour: endHour, minute: endMinute);
      }

      _error = null;
    } catch (e) {
      _error = '加载设置失败：$e';
      print(_error);
    } finally {
      notifyListeners();
    }
  }

  /// 设置通知总开关
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await _storage.setValue(_KEY_ENABLED, value);
    notifyListeners();
  }

  /// 设置通知声音开关
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _storage.setValue(_KEY_SOUND, value);
    notifyListeners();
  }

  /// 设置通知振动开关
  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _storage.setValue(_KEY_VIBRATION, value);
    notifyListeners();
  }

  /// 设置免打扰时间开关
  Future<void> setQuietHoursEnabled(bool value) async {
    _quietHoursEnabled = value;
    await _storage.setValue(_KEY_QUIET_HOURS, value);
    notifyListeners();
  }

  /// 验证免打扰时间设置是否有效
  /// [start] 开始时间
  /// [end] 结束时间
  /// 返回 true 表示时间设置有效，false 表示无效
  bool _validateQuietHours(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return startMinutes != endMinutes;
  }

  /// 设置免打扰开始时间
  /// [time] 新的开始时间
  /// 如果开始时间等于结束时间，将抛出异常
  Future<void> setQuietHoursStart(TimeOfDay time) async {
    if (!_validateQuietHours(time, _quietHoursEnd)) {
      throw Exception('开始时间不能等于结束时间');
    }
    _quietHoursStart = time;
    await _storage.setValue(_KEY_QUIET_START_HOUR, time.hour);
    await _storage.setValue(_KEY_QUIET_START_MINUTE, time.minute);
    notifyListeners();
  }

  /// 设置免打扰结束时间
  /// [time] 新的结束时间
  Future<void> setQuietHoursEnd(TimeOfDay time) async {
    _quietHoursEnd = time;
    await _storage.setValue(_KEY_QUIET_END_HOUR, time.hour);
    await _storage.setValue(_KEY_QUIET_END_MINUTE, time.minute);
    notifyListeners();
  }

  /// 判断当前是否处于免打扰时间
  /// 返回 true 表示当前在免打扰时间内，false 表示不在
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

  /// 导出所有通知设置
  /// 返回包含所有设置的 Map 对象，可用于保存或传输
  Map<String, dynamic> exportSettings() {
    return {
      'enabled': _enabled,
      'soundEnabled': _soundEnabled,
      'vibrationEnabled': _vibrationEnabled,
      'quietHoursEnabled': _quietHoursEnabled,
      'quietHoursStart': {
        'hour': _quietHoursStart.hour,
        'minute': _quietHoursStart.minute,
      },
      'quietHoursEnd': {
        'hour': _quietHoursEnd.hour,
        'minute': _quietHoursEnd.minute,
      },
    };
  }

  /// 批量保存设置
  Future<void> saveSettings() async {
    try {
      await Future.wait([
        _storage.setValue(_KEY_ENABLED, _enabled),
        _storage.setValue(_KEY_SOUND, _soundEnabled),
        _storage.setValue(_KEY_VIBRATION, _vibrationEnabled),
        _storage.setValue(_KEY_QUIET_HOURS, _quietHoursEnabled),
        _storage.setValue(_KEY_QUIET_START_HOUR, _quietHoursStart.hour),
        _storage.setValue(_KEY_QUIET_START_MINUTE, _quietHoursStart.minute),
        _storage.setValue(_KEY_QUIET_END_HOUR, _quietHoursEnd.hour),
        _storage.setValue(_KEY_QUIET_END_MINUTE, _quietHoursEnd.minute),
      ]);
      _error = null;
    } catch (e) {
      _error = '保存设置失败：$e';
      print(_error);
    }
  }

  /// 导入设置
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      if (!_validateSettings(settings)) {
        throw Exception('无效的设置数据');
      }

      _enabled = settings['enabled'] ?? true;
      _soundEnabled = settings['soundEnabled'] ?? true;
      _vibrationEnabled = settings['vibrationEnabled'] ?? true;
      _quietHoursEnabled = settings['quietHoursEnabled'] ?? false;

      final startMap = settings['quietHoursStart'];
      if (startMap != null) {
        _quietHoursStart = TimeOfDay(
          hour: startMap['hour'] ?? 22,
          minute: startMap['minute'] ?? 0,
        );
      }

      final endMap = settings['quietHoursEnd'];
      if (endMap != null) {
        _quietHoursEnd = TimeOfDay(
          hour: endMap['hour'] ?? 7,
          minute: endMap['minute'] ?? 0,
        );
      }

      await saveSettings();
      _error = null;
    } catch (e) {
      _error = '导入设置失败：$e';
      print(_error);
    } finally {
      notifyListeners();
    }
  }

  /// 验证设置数据
  bool _validateSettings(Map<String, dynamic> settings) {
    if (!settings.containsKey('enabled')) return false;
    if (!settings.containsKey('soundEnabled')) return false;
    if (!settings.containsKey('vibrationEnabled')) return false;
    if (!settings.containsKey('quietHoursEnabled')) return false;

    final startMap = settings['quietHoursStart'];
    final endMap = settings['quietHoursEnd'];

    if (startMap == null || endMap == null) return false;
    if (!startMap.containsKey('hour') || !startMap.containsKey('minute'))
      return false;
    if (!endMap.containsKey('hour') || !endMap.containsKey('minute'))
      return false;

    return true;
  }
}
