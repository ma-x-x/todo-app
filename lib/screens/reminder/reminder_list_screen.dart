import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/todo.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_form_screen.dart';

class ReminderListScreen extends StatefulWidget {
  final Todo todo;

  const ReminderListScreen({super.key, required this.todo});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ReminderProvider>().fetchReminders(widget.todo.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒设置'),
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = provider.getRemindersForTodo(widget.todo.id!);
          if (reminders.isEmpty) {
            return const Center(child: Text('暂无提醒，点击右下角添加'));
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return ListTile(
                leading: Icon(
                  reminder.notifyType == 'email'
                      ? Icons.email
                      : Icons.notifications,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  '${_getRemindTypeText(reminder.remindType)} - ${_formatDateTime(reminder.remindAt)}',
                ),
                subtitle: Text(
                  '通知方式: ${reminder.notifyType == 'email' ? '邮件' : '推送'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReminderFormScreen(
                              todoId: widget.todo.id!,
                              todoTitle: widget.todo.title,
                              reminder: reminder,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, reminder),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReminderFormScreen(
                todoId: widget.todo.id!,
                todoTitle: widget.todo.title,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getRemindTypeText(String remindType) {
    switch (remindType) {
      case 'once':
        return '单次提醒';
      case 'daily':
        return '每日提醒';
      case 'weekly':
        return '每周提醒';
      default:
        return '未知类型';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showDeleteDialog(BuildContext context, reminder) async {
    //打印reminder和widget.todo
    print('reminder: $reminder');
    print('widget.todo: ${widget.todo}');

    if (reminder.id == null || widget.todo.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法删除：提醒ID或待办ID为空')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个提醒吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<ReminderProvider>().deleteReminder(
              widget.todo.id!,
              reminder.id!,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: ${e.toString()}')),
          );
        }
      }
    }
  }
}
