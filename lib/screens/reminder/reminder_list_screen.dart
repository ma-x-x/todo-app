import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.fetchReminders(widget.todo.id!),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final reminders = provider.getRemindersForTodo(widget.todo.id!);
          if (reminders.isEmpty) {
            return const Center(child: Text('暂无提醒，点击右下角添加'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      reminder.notifyType == 'email'
                          ? Icons.email_outlined
                          : Icons.notifications_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    reminder.remindType == 'once'
                        ? '单次提醒'
                        : reminder.remindType == 'daily'
                            ? '每日提醒'
                            : '每周提醒',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '提醒时间: ${DateFormat('yyyy-MM-dd HH:mm').format(reminder.remindAt)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '通知方式: ${reminder.notifyType == 'email' ? '邮件' : '推送'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () =>
                        _showDeleteConfirmation(context, reminder.id!),
                  ),
                  onTap: () {
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

  Future<void> _showDeleteConfirmation(
      BuildContext context, int reminderId) async {
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
              reminderId,
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
