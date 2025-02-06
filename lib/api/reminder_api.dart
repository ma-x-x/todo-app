import '../models/reminder.dart';
import 'api_client.dart';

class ReminderApi {
  final ApiClient _client;

  ReminderApi(this._client);

  Future<List<Reminder>> getReminders(int todoId) async {
    try {
      final response = await _client.get('/reminders/todo/$todoId');

      // 根据swagger文档，响应包含items和total
      final data = response.data as Map<String, dynamic>;
      print('data: $data');
      return (data['items'] as List).map((json) {
        print('json: $json');
        return Reminder.fromJson(json);
      }).toList();
    } catch (e) {
      print('获取提醒列表失败: $e');
      rethrow;
    }
  }

  Future<Reminder> createReminder(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/reminders', data: data);
      // 根据swagger文档，创建成功返回CreateResponse
      return Reminder.fromJson(response.data['reminder']);
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
