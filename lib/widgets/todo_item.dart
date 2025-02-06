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
      endActionPane: _buildActionPane(context),
      child: _buildTodoListTile(context),
    );
  }

  ActionPane _buildActionPane(BuildContext context) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        _buildEditAction(context),
        _buildDeleteAction(context),
      ],
    );
  }

  Widget _buildTodoListTile(BuildContext context) {
    return ListTile(
      leading: _buildCheckbox(context),
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailingButtons(context),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: todo.completed,
      onChanged: (value) => context.read<TodoProvider>().toggleTodoStatus(todo),
    );
  }

  Widget _buildTitle() {
    return Text(
      todo.title,
      style: TextStyle(
        decoration: todo.completed ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todo.description?.isNotEmpty ?? false) Text(todo.description!),
        if (todo.category != null) _buildCategoryChip(),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Chip(
      label: Text(todo.category!.name),
      backgroundColor: todo.category!.color != null
          ? Color(int.parse(todo.category!.color!.replaceFirst('#', 'FF'),
              radix: 16))
          : null,
    );
  }

  Widget _buildTrailingButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: todo.hasActiveReminder() ? Colors.orange : Colors.grey,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReminderListScreen(todo: todo),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TodoFormScreen(todo: todo),
              ),
            );
          },
        ),
      ],
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
      onPressed: (context) => _showDeleteConfirmation(context),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: Icons.delete,
      label: '删除',
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个待办事项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final todoProvider = context.read<TodoProvider>();
      final slidable = Slidable.of(context);
      try {
        await todoProvider.deleteTodo(todo.id!);
        slidable?.close();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }
}
