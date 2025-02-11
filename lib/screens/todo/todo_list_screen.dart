import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/filter_provider.dart';
import '../../providers/todo_provider.dart';
import '../reminder/reminder_list_screen.dart';
import 'todo_filter_screen.dart';
import 'todo_form_screen.dart';
import 'todo_search_delegate.dart';

/// 待办事项列表页面
/// 显示所有待办事项，支持筛选、搜索和基本的增删改查操作
/// 每个待办事项显示标题、描述、分类、优先级等信息
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = Future(() async {
      if (!mounted) return;
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      await todoProvider.ensureInitialized();
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    await todoProvider.loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todoList),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchHint,
            onPressed: () {
              showSearch(context: context, delegate: TodoSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filters,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TodoFilterScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: _refresh,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          return Consumer2<TodoProvider, FilterProvider>(
            builder: (context, todoProvider, filterProvider, child) {
              final todos = todoProvider.getFilteredTodos(filterProvider);

              if (todos.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: theme.colorScheme.primary
                              .withAlpha((0.5 * 255).round()),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTodos,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noTodosHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  final category = todo.category;
                  final categoryColor = category?.color != null
                      ? Color(int.parse(
                          category!.color!.replaceFirst('#', 'FF'),
                          radix: 16))
                      : null;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: todo.completed
                        ? theme.colorScheme.surfaceContainer
                            .withAlpha((0.6 * 255).round())
                        : theme.colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReminderListScreen(todo: todo),
                          ),
                        );
                      },
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TodoFormScreen(todo: todo),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: todo.completed ? 0.6 : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Checkbox with custom style
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: todo.completed
                                        ? (categoryColor ??
                                            theme.colorScheme.primary)
                                        : theme.colorScheme.outlineVariant,
                                    width: 1.5,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      todoProvider.toggleTodoStatus(todo);
                                    },
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Icon(
                                          todo.completed ? Icons.check : null,
                                          key: ValueKey(todo.completed),
                                          color: todo.completed
                                              ? (categoryColor ??
                                                  theme.colorScheme.primary)
                                              : null,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            todo.title,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                              decoration: todo.completed
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: todo.completed
                                                  ? theme.colorScheme
                                                      .onSurfaceVariant
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (todo.hasActiveReminder())
                                          Icon(
                                            Icons.notifications_active_outlined,
                                            size: 18,
                                            color: categoryColor ??
                                                theme.colorScheme.primary,
                                          ),
                                      ],
                                    ),
                                    if (todo.description?.isNotEmpty ??
                                        false) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        todo.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (category != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: (categoryColor ??
                                                      theme.colorScheme.primary)
                                                  .withAlpha(
                                                      (0.1 * 255).round()),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              category.name,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: categoryColor ??
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        if (category != null)
                                          const SizedBox(width: 8),
                                        Icon(
                                          _getPriorityIcon(todo.priority),
                                          size: 16,
                                          color: _getPriorityColor(
                                              todo.priority, theme),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getPriorityText(todo.priority, l10n),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: _getPriorityColor(
                                                todo.priority, theme),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.outlined(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                style: IconButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                  side: BorderSide(
                                    color: theme.colorScheme.primary
                                        .withAlpha((0.2 * 255).round()),
                                  ),
                                ),
                                tooltip: l10n.edit,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TodoFormScreen(todo: todo),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton.outlined(
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                style: IconButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(
                                    color: theme.colorScheme.error
                                        .withAlpha((0.2 * 255).round()),
                                  ),
                                ),
                                tooltip: l10n.delete,
                                onPressed: () =>
                                    _confirmDelete(context, todo.id!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'todo_add_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TodoFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newTodo),
      ),
    );
  }

  /// 获取优先级对应的图标
  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.remove;
    }
  }

  /// 获取优先级对应的颜色
  Color _getPriorityColor(String priority, ThemeData theme) {
    switch (priority) {
      case 'high':
        return theme.colorScheme.error;
      case 'low':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// 获取优先级的显示文本
  String _getPriorityText(String priority, AppLocalizations l10n) {
    switch (priority) {
      case 'high':
        return l10n.priorityHigh;
      case 'low':
        return l10n.priorityLow;
      default:
        return l10n.priorityMedium;
    }
  }

  /// 显示删除确认对话框
  /// [context] 构建上下文
  /// [id] 待删除的待办事项ID
  Future<void> _confirmDelete(BuildContext context, int id) async {
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
        await context.read<TodoProvider>().deleteTodo(id);
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
