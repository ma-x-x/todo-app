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
      return Reminder.fromJson(response.data);
    } catch (e) {
      print('创建提醒失败: $e');
      rethrow;
    }
  }

  Future<Reminder> updateReminder(int id, Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/reminders/$id', data: data);
      return Reminder.fromJson(response.data);
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
