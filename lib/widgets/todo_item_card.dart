import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/reminder/reminder_list_screen.dart';
import '../screens/todo/todo_form_screen.dart';
import '../utils/priority_utils.dart';

class TodoItemCard extends StatelessWidget {
  final Todo todo;

  const TodoItemCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = todo.category;
    final categoryColor = category?.color != null
        ? Color(int.parse(category!.color!.replaceFirst('#', 'FF'), radix: 16))
        : null;

    return Card(
      elevation: 0,
      color: todo.completed
          ? theme.colorScheme.surfaceContainer.withAlpha((0.6 * 255).round())
          : theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReminderListScreen(todo: todo)),
        ),
        onLongPress: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TodoFormScreen(todo: todo)),
        ),
        child: Opacity(
          opacity: todo.completed ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildCheckbox(context, categoryColor, theme),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContent(context, categoryColor, theme),
                ),
                _buildActions(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      BuildContext context, Color? categoryColor, ThemeData theme) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: todo.completed
              ? (categoryColor ?? theme.colorScheme.primary)
              : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.read<TodoProvider>().toggleTodoStatus(todo),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                todo.completed ? Icons.check : null,
                key: ValueKey(todo.completed),
                color: todo.completed
                    ? (categoryColor ?? theme.colorScheme.primary)
                    : null,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Color? categoryColor, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                todo.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  decoration:
                      todo.completed ? TextDecoration.lineThrough : null,
                  color: todo.completed
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
            ),
            if (todo.hasActiveReminder())
              Icon(
                Icons.notifications_active_outlined,
                size: 18,
                color: categoryColor ?? theme.colorScheme.primary,
              ),
          ],
        ),
        if (todo.description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(
            todo.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 4),
        _buildTags(context, categoryColor, theme),
      ],
    );
  }

  Widget _buildTags(
      BuildContext context, Color? categoryColor, ThemeData theme) {
    final category = todo.category;
    return Row(
      children: [
        if (category != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (categoryColor ?? theme.colorScheme.primary)
                  .withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: categoryColor ?? theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Icon(
          PriorityUtils.getIcon(todo.priority),
          size: 16,
          color: PriorityUtils.getColor(todo.priority, theme),
        ),
        const SizedBox(width: 4),
        Text(
          PriorityUtils.getText(todo.priority, context),
          style: theme.textTheme.labelSmall?.copyWith(
            color: PriorityUtils.getColor(todo.priority, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          icon: const Icon(Icons.edit_outlined, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(
              color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TodoFormScreen(todo: todo)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          icon: const Icon(Icons.delete_outline, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(
              color: theme.colorScheme.error.withAlpha((0.2 * 255).round()),
            ),
          ),
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<TodoProvider>().deleteTodo(todo.id!);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
}
