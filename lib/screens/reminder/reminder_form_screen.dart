import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:provider/provider.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? '新建提醒' : '编辑提醒'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('提醒时间'),
              subtitle: Text(_formatDateTime(_selectedDateTime)),
              trailing: const Icon(Icons.arrow_forward_ios),
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
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('提醒类型'),
                ),
                RadioListTile<String>(
                  title: const Text('单次提醒'),
                  value: 'once',
                  groupValue: _selectedRemindType,
                  onChanged: (value) {
                    setState(() {
                      _selectedRemindType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('每日提醒'),
                  value: 'daily',
                  groupValue: _selectedRemindType,
                  onChanged: (value) {
                    setState(() {
                      _selectedRemindType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('每周提醒'),
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
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('通知方式'),
                ),
                RadioListTile<String>(
                  title: const Text('推送通知'),
                  value: 'push',
                  groupValue: _selectedNotifyType,
                  onChanged: (value) {
                    setState(() {
                      _selectedNotifyType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('邮件通知'),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('保存'),
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
          SnackBar(content: Text('保存失败: $e')),
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