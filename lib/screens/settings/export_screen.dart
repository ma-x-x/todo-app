import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../providers/todo_provider.dart';
import '../../services/export_service.dart';
import '../../utils/error_handler.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.export),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: Text(AppLocalizations.of(context)!.exportToCsv),
            subtitle: Text(AppLocalizations.of(context)!.exportToCsvDesc),
            onTap: () => _exportToCsv(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(AppLocalizations.of(context)!.exportToPdf),
            subtitle: Text(AppLocalizations.of(context)!.exportToPdfDesc),
            onTap: () => _exportToPdf(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCsv(BuildContext context) async {
    try {
      final todoProvider = context.read<TodoProvider>();
      final categoryProvider = context.read<CategoryProvider>();

      final categoryMap = Map<int, Category>.fromEntries(
        categoryProvider.categories
            .where((c) => c.id != null)
            .map((c) => MapEntry(c.id!, c)),
      );

      final filePath = await ExportService().exportToCsv(
        todos: todoProvider.todos,
        categories: categoryMap,
      );

      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.exportSuccess),
            content: Text(AppLocalizations.of(context)!.shareExportQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.yes),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          final file = XFile(filePath);
          await Share.shareXFiles(
            [file],
            subject: 'Todo App Export (CSV)',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _exportToPdf(BuildContext context) async {
    // 类似的实现...
  }
}
