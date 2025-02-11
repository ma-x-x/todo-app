import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../services/notification_service.dart';

class ReminderFormScreen extends StatefulWidget {
  final int todoId;
  final String todoTitle;
  final Reminder? reminder;

  const ReminderFormScreen({
    super.key,
    required this.todoId,
    required this.todoTitle,
    this.reminder,
  });

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  late DateTime _selectedDateTime;
  String _selectedRemindType = 'once';
  String _selectedNotifyType = 'push';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _selectedDateTime = widget.reminder!.remindAt;
      _selectedRemindType = widget.reminder!.remindType;
      _selectedNotifyType = widget.reminder!.notifyType;
    } else {
      _selectedDateTime = DateTime.now().add(const Duration(minutes: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.reminder == null ? l10n.newReminder : l10n.editReminder),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                DatePicker.showDateTimePicker(
                  context,
                  currentTime: _selectedDateTime,
                  minTime: DateTime.now(),
                  onConfirm: (date) {
                    setState(() {
                      _selectedDateTime = date;
                    });
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reminderTime,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(_selectedDateTime),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.reminderType,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.reminderOnce),
                  value: 'once',
                  groupValue: _selectedRemindType,
                  onChanged: (value) {
                    setState(() {
                      _selectedRemindType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.reminderDaily),
                  value: 'daily',
                  groupValue: _selectedRemindType,
                  onChanged: (value) {
                    setState(() {
                      _selectedRemindType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.reminderWeekly),
                  value: 'weekly',
                  groupValue: _selectedRemindType,
                  onChanged: (value) {
                    setState(() {
                      _selectedRemindType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.notifyType,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.notifyPush),
                  value: 'push',
                  groupValue: _selectedNotifyType,
                  onChanged: (value) {
                    setState(() {
                      _selectedNotifyType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.notifyEmail),
                  value: 'email',
                  groupValue: _selectedNotifyType,
                  onChanged: (value) {
                    setState(() {
                      _selectedNotifyType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(l10n.save),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = NotificationService();
      final hasPermission = await notificationService.checkPermissions();

      if (!hasPermission && mounted) {
        final requestPermission = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('需要通知权限'),
            content: const Text('为了发送提醒通知，我们需要获取通知和闹钟权限。是否授予权限？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('授权'),
              ),
            ],
          ),
        );

        if (requestPermission != true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('未获得权限，无法设置提醒')),
            );
          }
          return;
        }
      }

      final reminder = Reminder(
        id: widget.reminder?.id,
        todoId: widget.todoId,
        remindAt: _selectedDateTime,
        remindType: _selectedRemindType,
        notifyType: _selectedNotifyType,
        status: false,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.reminder == null) {
        await context.read<ReminderProvider>().createReminder(
              reminder,
              widget.todoTitle,
            );
      } else {
        await context.read<ReminderProvider>().updateReminder(
              reminder,
              widget.todoTitle,
            );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: ${e.toString()}'),
            action: SnackBarAction(
              label: '重试',
              onPressed: _submit,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
