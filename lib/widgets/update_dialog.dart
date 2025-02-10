import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.system_update, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text(
                  '发现新版本 ${updateInfo.version}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '更新内容：',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  updateInfo.description,
                  style: theme.textTheme.bodyMedium,
                ),
                if (updateInfo.isForced) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '这是一个强制更新版本',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!updateInfo.isForced)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('稍后再说'),
                  ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () async {
                    final url = updateInfo.downloadUrl;
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url);
                    }
                    if (context.mounted && !updateInfo.isForced) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('立即更新'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
