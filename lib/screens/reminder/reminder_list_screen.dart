import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/todo.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_form_screen.dart';

/// 提醒列表页面
/// 显示指定待办事项的所有提醒
/// 支持添加、编辑和删除提醒
class ReminderListScreen extends StatefulWidget {
  /// 关联的待办事项
  final Todo todo;

  const ReminderListScreen({super.key, required this.todo});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = Future(() async {
      if (!mounted) return;
      final reminderProvider =
          Provider.of<ReminderProvider>(context, listen: false);
      await reminderProvider.ensureInitialized(widget.todo.id!);
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final reminderProvider =
        Provider.of<ReminderProvider>(context, listen: false);
    await reminderProvider.loadReminders(widget.todo.id!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminders),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadingError(snapshot.error.toString()),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: _refresh,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final reminderProvider = Provider.of<ReminderProvider>(context);
          final reminders =
              reminderProvider.getRemindersForTodo(widget.todo.id!);
          if (reminders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 48,
                      color: theme.colorScheme.primary
                          .withAlpha((0.5 * 255).round()),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noReminders,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noRemindersHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withAlpha((0.1 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            reminder.notifyType == 'email'
                                ? Icons.email_outlined
                                : Icons.notifications_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getRemindTypeText(reminder.remindType, l10n),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(reminder.remindAt),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withAlpha((0.1 * 255).round()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getNotifyTypeText(reminder.notifyType, l10n),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.outlined(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          style: IconButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: theme.colorScheme.primary
                                  .withAlpha((0.2 * 255).round()),
                            ),
                          ),
                          tooltip: l10n.edit,
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
                        const SizedBox(width: 8),
                        IconButton.outlined(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          style: IconButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(
                              color: theme.colorScheme.error
                                  .withAlpha((0.2 * 255).round()),
                            ),
                          ),
                          tooltip: l10n.delete,
                          onPressed: () =>
                              _showDeleteConfirmation(context, reminder.id!),
                        ),
                      ],
                    ),
                  ),
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
        tooltip: l10n.newReminder,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 获取提醒类型的显示文本
  String _getRemindTypeText(String remindType, AppLocalizations l10n) {
    switch (remindType) {
      case 'once':
        return '单次提醒';
      case 'daily':
        return '每日提醒';
      case 'weekly':
        return '每周提醒';
      default:
        throw Exception('Unknown remind type: $remindType');
    }
  }

  /// 获取通知类型的显示文本
  String _getNotifyTypeText(String notifyType, AppLocalizations l10n) {
    switch (notifyType) {
      case 'email':
        return '邮件';
      case 'push':
        return '推送';
      default:
        throw Exception('Unknown notify type: $notifyType');
    }
  }

  /// 显示删除确认对话框
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
