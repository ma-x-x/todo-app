import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.themeSettings),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    theme,
                    title: l10n.themeSystem,
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setThemeMode(value!),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  _buildThemeOption(
                    theme,
                    title: l10n.themeLight,
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setThemeMode(value!),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  _buildThemeOption(
                    theme,
                    title: l10n.themeDark,
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setThemeMode(value!),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeData theme, {
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
    );
  }
}
