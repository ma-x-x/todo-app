import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/category.dart';
import '../models/reminder.dart';
import '../models/todo.dart';

/// 备份服务类
/// 负责应用数据的导出和导入功能，包括待办事项、分类和提醒事项的备份
class BackupService {
  // 单例模式实现
  static final BackupService _instance = BackupService._();
  factory BackupService() => _instance;

  BackupService._();

  /// 导出应用数据
  /// 将待办事项、分类和提醒事项导出为JSON文件
  ///
  /// 参数:
  /// - todos: 待办事项列表
  /// - categories: 分类列表
  /// - reminders: 提醒事项列表
  ///
  /// 返回: 导出文件的路径
  Future<String> exportData({
    required List<Todo> todos,
    required List<Category> categories,
    required List<Reminder> reminders,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Web平台暂不支持备份功能');
    }
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

  /// 导入备份数据
  /// 从JSON字符串中恢复应用数据
  ///
  /// 参数:
  /// - jsonStr: JSON格式的备份数据字符串
  ///
  /// 返回: 包含恢复的数据的Map对象
  /// 可能抛出 FormatException 如果备份文件格式无效
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

  /// 分享备份文件
  /// 使用系统分享功能分享备份文件
  ///
  /// 参数:
  /// - filePath: 要分享的备份文件路径
  Future<void> shareBackup(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: 'Todo App Backup',
      text: 'Here is your Todo App backup file',
    );
  }
}
