import 'package:dio/dio.dart';
import 'api_client.dart';

class ReminderApi {
  final ApiClient _client;

  ReminderApi(this._client);

  Future<Response> getReminders(int todoId) {
    return _client.get('/reminders/todo/$todoId');
  }

  Future<Response> createReminder(Map<String, dynamic> data) {
    return _client.post('/reminders', data: data);
  }

  Future<Response> updateReminder(int id, Map<String, dynamic> data) {
    return _client.put('/reminders/$id', data: data);
  }

  Future<Response> deleteReminder(int id) {
    return _client.delete('/reminders/$id');
  }
} 