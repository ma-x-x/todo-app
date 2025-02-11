import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../routes/app_router.dart';
import '../../services/update_service.dart';
import '../../widgets/update_dialog.dart';
import 'backup_screen.dart';
import 'export_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSettingsCard(
            theme,
            children: [
              _buildSettingTile(
                theme,
                icon: Icons.language,
                title: l10n.language,
                trailing: Consumer<LocaleProvider>(
                  builder: (context, provider, child) {
                    return DropdownButton<Locale>(
                      value: provider.locale ?? Localizations.localeOf(context),
                      items: L10n.all.map((locale) {
                        return DropdownMenuItem(
                          value: locale,
                          child: Text(_getLanguageName(locale.languageCode)),
                        );
                      }).toList(),
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          provider.setLocale(newLocale);
                        }
                      },
                    );
                  },
                ),
              ),
              _buildSettingTile(
                theme,
                icon: Icons.palette,
                title: l10n.themeSettings,
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.themeSettings),
              ),
              _buildSettingTile(
                theme,
                icon: Icons.notifications,
                title: l10n.notifications,
                onTap: () => Navigator.pushNamed(
                    context, AppRouter.notificationSettings),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            theme,
            children: [
              _buildSettingTile(
                theme,
                icon: Icons.backup,
                title: l10n.backup,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BackupScreen()),
                ),
              ),
              _buildSettingTile(
                theme,
                icon: Icons.file_download,
                title: l10n.export,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            theme,
            children: [
              _buildSettingTile(
                theme,
                icon: Icons.system_update,
                title: '检查更新',
                onTap: () => _checkForUpdates(context),
              ),
              _buildSettingTile(
                theme,
                icon: Icons.logout,
                title: l10n.logout,
                iconColor: theme.colorScheme.error,
                textColor: theme.colorScheme.error,
                onTap: () => _showLogoutDialog(context),
              ),
              _buildSettingTile(
                theme,
                icon: Icons.info,
                title: l10n.about,
                onTap: () => _showAboutDialog(context),
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, {required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
          ),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 20),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: theme.colorScheme.outlineVariant,
          ),
      ],
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return languageCode;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmLogout),
        content: Text(AppLocalizations.of(context)!.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<AuthProvider>().logout();

        if (context.mounted) {
          // 确保清除所有路由历史并导航到登录页面
          await Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.login,
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('退出登录失败: $e')),
          );
        }
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppLocalizations.of(context)!.appTitle,
        applicationVersion: '1.0.0',
        applicationIcon: const FlutterLogo(size: 50),
        children: [
          Text(AppLocalizations.of(context)!.aboutContent),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    final updateService = context.read<UpdateService>();
    final updateInfo = await updateService.checkForUpdates();

    if (updateInfo == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已是最新版本')),
      );
      return;
    }

    if (updateInfo != null && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: !updateInfo.isForced,
        builder: (context) => UpdateDialog(updateInfo: updateInfo),
      );
    }
  }
}
