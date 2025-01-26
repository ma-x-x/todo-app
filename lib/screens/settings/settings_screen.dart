import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../routes/app_router.dart';
import 'backup_screen.dart';
import 'export_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.language),
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
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(AppLocalizations.of(context)!.themeSettings),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.themeSettings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context)!.notifications),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.notificationSettings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(AppLocalizations.of(context)!.backup),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: Text(AppLocalizations.of(context)!.export),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () => _showLogoutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.about),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
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
      await context.read<AuthProvider>().logout();
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
}
