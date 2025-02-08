import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/reminder_api.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  final ReminderApi _reminderApi;
  final NotificationService _notificationService = NotificationService();
  final Map<int, List<Reminder>> _reminders = {}; // todoId -> List<Reminder>
  bool _isLoading = false;
  String? _error;

  ReminderProvider() : _reminderApi = ReminderApi(ApiClient());

  List<Reminder> getRemindersForTodo(int todoId) => _reminders[todoId] ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reminder> get allReminders {
    return _reminders.values.expand((list) => list).toList();
  }

  Future<void> fetchReminders(int todoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reminders = await _reminderApi.getReminders(todoId);
      _reminders[todoId] = reminders;
    } catch (e) {
      _error = '获取提醒列表失败：${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReminder(Reminder reminder, String todoTitle) async {
    try {
      // 先请求权限
      await _notificationService.requestPermissions();

      final newReminder =
          await _reminderApi.createReminder(reminder.toRequestJson());
      _addReminderToList(reminder.todoId, newReminder);
      await _notificationService.scheduleNotification(newReminder, todoTitle);
      notifyListeners();
    } catch (e) {
      print('创建提醒失败: $e');
      rethrow;
    }
  }

  void _addReminderToList(int todoId, Reminder reminder) {
    if (!_reminders.containsKey(todoId)) {
      _reminders[todoId] = [];
    }
    _reminders[todoId]!.add(reminder);
  }

  Future<void> updateReminder(Reminder reminder, String todoTitle) async {
    try {
      final updatedReminder = await _reminderApi.updateReminder(
        reminder.id!,
        reminder.toRequestJson(),
      );

      final todoReminders = _reminders[reminder.todoId];
      if (todoReminders != null) {
        final index = todoReminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          // 取消旧的通知
          await _notificationService.cancelNotification(reminder.id!);
          // 设置新的通知
          await _notificationService.scheduleNotification(
              updatedReminder, todoTitle);

          todoReminders[index] = updatedReminder;
          notifyListeners();
        }
      }
    } catch (e) {
      print('更新提醒失败: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(int todoId, int reminderId) async {
    try {
      await _reminderApi.deleteReminder(reminderId);
      // 取消通知
      await _notificationService.cancelNotification(reminderId);

      final todoReminders = _reminders[todoId];
      if (todoReminders != null) {
        todoReminders.removeWhere((reminder) => reminder.id == reminderId);
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
      if (!_reminders.containsKey(reminder.todoId)) {
        _reminders[reminder.todoId] = [];
      }
      _reminders[reminder.todoId]!.add(reminder);
    }
    notifyListeners();
  }
}
