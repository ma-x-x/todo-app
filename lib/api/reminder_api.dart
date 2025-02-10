import '../models/reminder.dart';
import 'api_client.dart';

class ReminderApi {
  final ApiClient _client;

  ReminderApi(this._client);

  Future<List<Reminder>> getReminders(int todoId) async {
    try {
      final response = await _client.get('/reminders/todo/$todoId');

      // 处理新的响应格式
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('items')) {
        // 从 items 字段获取提醒列表
        final items = response.data['items'] as List;
        return items.map((json) {
          print('正在解析提醒: $json');
          return Reminder.fromJson(json);
        }).toList();
      }

      // 如果没有 items 字段，返回空列表
      print('提醒列表为空');
      return [];
    } catch (e) {
      print('获取提醒列表失败: $e');
      rethrow;
    }
  }

  Future<Reminder> createReminder(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/reminders', data: data);
      print('创建提醒响应: ${response.data}'); // 调试日志

      // 直接从响应数据中获取 id
      final id = response.data['id'] as int;
      print('获取到的提醒ID: $id'); // 调试日志

      // 使用 id 和原始数据构建完整的 Reminder 对象
      return Reminder(
        id: id,
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

      // 由于后端只返回成功状态，我们使用原始数据构建更新后的 Reminder 对象
      return Reminder(
        id: id,
        todoId: data['todo_id'] as int,
        remindAt: DateTime.parse(data['remind_at'] as String),
        remindType: data['remind_type'] as String,
        notifyType: data['notify_type'] as String,
        status: false,
        createdAt: DateTime.now(), // 保持原有的创建时间更好，但这里我们没有原始数据
        updatedAt: DateTime.now(),
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
