import '../api/api_client.dart';
import '../models/reminder.dart';

class ReminderApi {
  final ApiClient _client;

  ReminderApi(this._client);

  Future<List<Reminder>> getReminders(int todoId) async {
    try {
      final response = await _client.get('/reminders/todo/$todoId');
      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('items') || data['items'] is! List) {
        throw '响应数据格式错误';
      }

      return (data['items'] as List)
          .map((json) => Reminder.fromJson(json))
          .toList();
    } catch (e) {
      print('获取提醒列表失败: $e');
      rethrow;
    }
  }

  Future<Reminder> createReminder(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/reminders', data: data);
      return Reminder(
        id: response.data['id'] as int,
        todoId: data['todoId'] as int,
        remindAt: DateTime.parse(data['remindAt'] as String),
        remindType: data['remindType'] as String,
        notifyType: data['notifyType'] as String,
        status: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      print('创建提醒失败: $e');
      rethrow;
    }
  }

  Future<Reminder> updateReminder(int id, Map<String, dynamic> data) async {
    try {
      await _client.put('/reminders/$id', data: data);
      return Reminder(
        id: id,
        todoId: data['todoId'] as int,
        remindAt: DateTime.parse(data['remindAt'] as String),
        remindType: data['remindType'] as String,
        notifyType: data['notifyType'] as String,
        status: data['status'] as bool? ?? false,
        updatedAt: DateTime.now(),
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('更新提醒失败: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      await _client.delete('/reminders/$id');
    } catch (e) {
      print('删除提醒失败: $e');
      rethrow;
    }
  }
}
