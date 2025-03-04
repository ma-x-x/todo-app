import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_settings_provider.dart';

/// 通知设置页面
/// 提供通知相关的各项设置
/// 包括开关通知、声音、振动，以及设置免打扰时间
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notificationSettings),
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.enableNotifications),
                subtitle:
                    Text(AppLocalizations.of(context)!.enableNotificationsDesc),
                value: provider.enabled,
                onChanged: provider.setEnabled,
              ),
              if (provider.enabled) ...[
                const Divider(),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.notificationSound),
                  value: provider.soundEnabled,
                  onChanged: provider.setSoundEnabled,
                ),
                SwitchListTile(
                  title:
                      Text(AppLocalizations.of(context)!.notificationVibration),
                  value: provider.vibrationEnabled,
                  onChanged: provider.setVibrationEnabled,
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.quietHours),
                  subtitle: Text(AppLocalizations.of(context)!.quietHoursDesc),
                  value: provider.quietHoursEnabled,
                  onChanged: provider.setQuietHoursEnabled,
                ),
                if (provider.quietHoursEnabled) ...[
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.quietHoursStart),
                    trailing: Text(_formatTimeOfDay(provider.quietHoursStart)),
                    onTap: () => _selectTime(
                      context,
                      provider.quietHoursStart,
                      provider.setQuietHoursStart,
                    ),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.quietHoursEnd),
                    trailing: Text(_formatTimeOfDay(provider.quietHoursEnd)),
                    onTap: () => _selectTime(
                      context,
                      provider.quietHoursEnd,
                      provider.setQuietHoursEnd,
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  /// 格式化时间显示
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 显示时间选择器
  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      onTimeSelected(time);
    }
  }
}
