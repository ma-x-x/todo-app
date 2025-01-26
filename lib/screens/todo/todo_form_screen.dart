import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;

  const TodoFormScreen({super.key, this.todo});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _priority = 'medium';
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title);
    _descriptionController = TextEditingController(text: widget.todo?.description);
    _priority = widget.todo?.priority ?? 'medium';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? l10n.newTodo : l10n.editTodo),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _titleController,
              label: l10n.title,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '${l10n.title} ${l10n.errorRequired}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: l10n.description,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: InputDecoration(
                labelText: l10n.priority,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'low',
                  child: Text(l10n.priorityLow),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text(l10n.priorityMedium),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text(l10n.priorityHigh),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final todo = Todo(
      id: widget.todo?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority,
      completed: widget.todo?.completed ?? false,
      createdAt: widget.todo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final provider = context.read<TodoProvider>();
      if (widget.todo == null) {
        await provider.createTodo(todo);
      } else {
        await provider.updateTodo(todo);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 