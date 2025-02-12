import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PriorityUtils {
  static IconData getIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.remove;
    }
  }

  static Color getColor(String priority, ThemeData theme) {
    switch (priority) {
      case 'high':
        return theme.colorScheme.error;
      case 'low':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }

  static String getText(String priority, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (priority) {
      case 'high':
        return l10n.priorityHigh;
      case 'low':
        return l10n.priorityLow;
      default:
        return l10n.priorityMedium;
    }
  }
}
