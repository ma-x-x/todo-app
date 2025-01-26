import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/category.dart';
import '../models/reminder.dart';
import '../models/todo.dart';

class BackupService {
  static final BackupService _instance = BackupService._();
  factory BackupService() => _instance;

  BackupService._();

  Future<String> exportData({
    required List<Todo> todos,
    required List<Category> categories,
    required List<Reminder> reminders,
  }) async {
    final data = {
      'todos': todos.map((todo) => todo.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };

    final jsonStr = jsonEncode(data);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/todo_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonStr);
    return file.path;
  }

  Future<Map<String, dynamic>> importData(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final todos =
          (data['todos'] as List).map((json) => Todo.fromJson(json)).toList();

      final categories = (data['categories'] as List)
          .map((json) => Category.fromJson(json))
          .toList();

      final reminders = (data['reminders'] as List)
          .map((json) => Reminder.fromJson(json))
          .toList();

      return {
        'todos': todos,
        'categories': categories,
        'reminders': reminders,
      };
    } catch (e) {
      throw const FormatException('Invalid backup file format');
    }
  }

  Future<void> shareBackup(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: 'Todo App Backup',
      text: 'Here is your Todo App backup file',
    );
  }
}
