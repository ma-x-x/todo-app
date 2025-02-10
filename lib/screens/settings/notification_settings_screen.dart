import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_settings_provider.dart';

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

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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

  Widget _buildSettingSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
