import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/reminder/reminder_list_screen.dart';
import '../screens/todo/todo_form_screen.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          _buildEditAction(context),
          _buildDeleteAction(context),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) => _toggleStatus(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.completed ? TextDecoration.lineThrough : null,
              color: todo.completed ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    todo.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (todo.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                                todo.category!.color!.replaceFirst('#', 'FF'),
                                radix: 16))
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        todo.category!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(int.parse(
                              todo.category!.color!.replaceFirst('#', 'FF'),
                              radix: 16)),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(todo.priority).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(todo.priority),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getPriorityColor(todo.priority),
                      ),
                    ),
                  ),
                  if (todo.hasActiveReminder())
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
          onTap: () => _navigateToReminders(context),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
        return '低';
      default:
        return priority;
    }
  }

  void _toggleStatus(BuildContext context) {
    context.read<TodoProvider>().toggleTodoStatus(todo);
  }

  void _navigateToReminders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderListScreen(todo: todo),
      ),
    );
  }

  SlidableAction _buildEditAction(BuildContext context) {
    return SlidableAction(
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TodoFormScreen(todo: todo)),
        );
      },
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      icon: Icons.edit,
      label: '编辑',
    );
  }

  SlidableAction _buildDeleteAction(BuildContext context) {
    return SlidableAction(
      onPressed: (_) => _showDeleteConfirmation(context),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: Icons.delete,
      label: '删除',
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    print('显示删除确认对话框');
    print('初始 context.mounted: ${context.mounted}');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个待办事项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    print('用户选择: $confirmed');
    print('确认后 context.mounted: ${context.mounted}');

    if (confirmed == true) {
      try {
        print('开始删除待办: ${todo.id}');
        await context.read<TodoProvider>().deleteTodo(todo.id!);
        print('删除成功');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      } catch (e) {
        print('删除失败: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }
}
