import 'package:flutter/foundation.dart';

import '../api/reminder_api.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

/// 提醒事项管理器
/// 负责管理待办事项的提醒功能，包括创建、更新、删除提醒
/// 同时负责调度本地通知
class ReminderProvider with ChangeNotifier {
  final ReminderApi _reminderApi;
  bool _isLoading = false;
  String? _error;
  final Map<int, List<Reminder>> _reminders = {};
  final Map<int, bool> _initializedTodos = {};
  final NotificationService _notificationService = NotificationService();

  /// 获取指定待办事项的所有提醒
  List<Reminder> getRemindersForTodo(int todoId) {
    return _reminders[todoId] ?? [];
  }

  /// 获取所有提醒列表
  List<Reminder> get allReminders =>
      _reminders.values.expand((reminders) => reminders).toList();

  ReminderProvider({required ReminderApi reminderApi})
      : _reminderApi = reminderApi;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> ensureInitialized(int todoId) async {
    if (_initializedTodos[todoId] == true) return;

    try {
      _isLoading = true;
      notifyListeners();

      final reminders = await _reminderApi.getReminders(todoId);
      _reminders[todoId] = reminders;
      _initializedTodos[todoId] = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('加载提醒失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReminders(int todoId) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final reminders = await _reminderApi.getReminders(todoId);
      _reminders[todoId] = reminders;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('加载提醒失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleError(String operation, dynamic error) {
    _error = error.toString();
    print('$operation失败: $error');
  }

  Future<void> createReminder(Reminder reminder, String todoTitle) async {
    try {
      final hasPermission = await _notificationService.requestPermissions();
      final newReminder =
          await _reminderApi.createReminder(reminder.toRequestJson());

      final reminderList = _reminders.putIfAbsent(reminder.todoId, () => []);
      reminderList.add(newReminder);

      if (!hasPermission) {
        _handleError('通知权限', '未获得通知权限，提醒将无法显示');
      } else {
        await _notificationService.scheduleNotification(newReminder, todoTitle);
      }

      notifyListeners();
    } catch (e) {
      _handleError('创建提醒', e);
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder, String todoTitle) async {
    try {
      if (!_reminders.containsKey(reminder.todoId)) return;

      final list = _reminders[reminder.todoId]!;
      final index = list.indexWhere((r) => r.id == reminder.id);
      if (index == -1) return;

      final updatedReminder = await _updateReminderAndNotification(
        list[index],
        reminder,
        todoTitle,
      );

      list[index] = updatedReminder;
      notifyListeners();
    } catch (e) {
      _handleError('更新提醒', e);
      rethrow;
    }
  }

  Future<Reminder> _updateReminderAndNotification(
    Reminder original,
    Reminder updated,
    String todoTitle,
  ) async {
    final updatedReminder = await _reminderApi.updateReminder(
      updated.id!,
      updated.toRequestJson(),
    );

    final result = updatedReminder.copyWith(
      createdAt: original.createdAt,
    );

    await _notificationService.cancelNotification(updated.id!);
    await _notificationService.scheduleNotification(result, todoTitle);

    return result;
  }

  Future<void> deleteReminder(int todoId, int reminderId) async {
    try {
      await _reminderApi.deleteReminder(reminderId);
      await _notificationService.cancelNotification(reminderId);

      if (_reminders.containsKey(todoId)) {
        _reminders[todoId]!.removeWhere((r) => r.id == reminderId);
        notifyListeners();
      }
    } catch (e) {
      print('删除提醒失败: $e');
      rethrow;
    }
  }

  Future<void> importReminders(List<dynamic> remindersData) async {
    _reminders.clear();
    for (var json in remindersData) {
      final reminder = Reminder.fromJson(json);
      final todoId = reminder.todoId;
      final reminderList = _reminders.putIfAbsent(todoId, () => []);
      reminderList.add(reminder);
    }
    notifyListeners();
  }

  Future<void> deleteRemindersForTodo(int todoId) async {
    try {
      final reminders = _reminders[todoId] ?? [];
      for (final reminder in reminders) {
        await _reminderApi.deleteReminder(reminder.id!);
        await _notificationService.cancelNotification(reminder.id!);
      }
      _reminders.remove(todoId);
      notifyListeners();
    } catch (e) {
      _handleError('批量删除提醒', e);
      rethrow;
    }
  }

  Future<void> cleanExpiredReminders() async {
    try {
      final now = DateTime.now();
      for (final todoId in _reminders.keys) {
        _reminders[todoId]?.removeWhere((reminder) {
          final isExpired = reminder.remindAt.isBefore(now);
          if (isExpired) {
            _notificationService.cancelNotification(reminder.id!);
          }
          return isExpired;
        });
      }
      notifyListeners();
    } catch (e) {
      _handleError('清理过期提醒', e);
    }
  }
}
