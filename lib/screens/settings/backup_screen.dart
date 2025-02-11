import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/todo_provider.dart';
import '../../services/backup_service.dart';
import '../../utils/error_handler.dart';

/// 备份页面
/// 提供数据的导入导出功能
/// 支持备份所有待办事项、分类和提醒数据
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.backup),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(AppLocalizations.of(context)!.exportData),
            subtitle: Text(AppLocalizations.of(context)!.exportDataDesc),
            onTap: () => _exportData(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(AppLocalizations.of(context)!.importData),
            subtitle: Text(AppLocalizations.of(context)!.importDataDesc),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }

  /// 导出数据
  /// [context] 构建上下文，用于访问Provider和显示对话框
  /// 将所有数据导出为JSON文件，并提供分享选项
  Future<void> _exportData(BuildContext context) async {
    try {
      final todoProvider = context.read<TodoProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final reminderProvider = context.read<ReminderProvider>();

      final filePath = await BackupService().exportData(
        todos: todoProvider.todos,
        categories: categoryProvider.categories,
        reminders: reminderProvider.allReminders,
      );

      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exportSuccess),
            content: Text(AppLocalizations.of(context)!.shareBackupQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.yes),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await BackupService().shareBackup(filePath);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e.toString());
      }
    }
  }

  /// 导入数据
  /// [context] 构建上下文，用于访问Provider和显示对话框
  /// 从JSON文件中导入数据，会覆盖现有数据
  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmImport),
            content: Text(AppLocalizations.of(context)!.confirmImportMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.import),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await context.read<TodoProvider>().importTodos(data['todos']);
          await context
              .read<CategoryProvider>()
              .importCategories(data['categories']);
          await context
              .read<ReminderProvider>()
              .importReminders(data['reminders']);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.importSuccess),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e.toString());
      }
    }
  }
}
