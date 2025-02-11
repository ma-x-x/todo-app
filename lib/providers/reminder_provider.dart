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

  Future<void> createReminder(Reminder reminder, String todoTitle) async {
    try {
      await _notificationService.requestPermissions();
      final newReminder =
          await _reminderApi.createReminder(reminder.toRequestJson());

      // 确保待办事项的提醒列表已初始化
      _reminders.putIfAbsent(reminder.todoId, () => []);
      _reminders[reminder.todoId]!.add(newReminder);

      await _notificationService.scheduleNotification(newReminder, todoTitle);
      notifyListeners();
    } catch (e) {
      print('创建提醒失败: $e');
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder, String todoTitle) async {
    try {
      if (!_reminders.containsKey(reminder.todoId)) return;

      final list = _reminders[reminder.todoId]!;
      final index = list.indexWhere((r) => r.id == reminder.id);
      if (index == -1) return;

      final originalReminder = list[index];
      final updatedReminder = await _reminderApi.updateReminder(
        reminder.id!,
        reminder.toRequestJson(),
      );

      list[index] = updatedReminder.copyWith(
        createdAt: originalReminder.createdAt,
      );

      await _notificationService.cancelNotification(reminder.id!);
      await _notificationService.scheduleNotification(
        list[index],
        todoTitle,
      );

      notifyListeners();
    } catch (e) {
      print('更新提醒失败: $e');
      rethrow;
    }
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
      _reminders.putIfAbsent(todoId, () => []).add(reminder);
    }
    notifyListeners();
  }
}
