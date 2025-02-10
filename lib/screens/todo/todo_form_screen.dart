import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/todo.dart';
import '../../providers/category_provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/common/custom_text_field.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;

  const TodoFormScreen({super.key, this.todo});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Category? _selectedCategory;
  late String _priority;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priority = 'medium';
    if (widget.todo != null) {
      _loadTodoDetail();
    }
  }

  Future<void> _loadTodoDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todo =
          await context.read<TodoProvider>().getTodoDetail(widget.todo!.id!);
      print('获取到的待办详情: ${todo.toJson()}');
      print('优先级值: ${todo.priority}');

      _titleController.text = todo.title;
      _descriptionController.text = todo.description ?? '';
      _selectedCategory = todo.category;

      setState(() {
        _priority = ['low', 'medium', 'high'].contains(todo.priority)
            ? todo.priority
            : 'medium';
      });
      print('设置的优先级值: $_priority');
    } catch (e) {
      print('加载待办详情失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    print('构建表单，当前优先级: $_priority');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.todo == null ? l10n.newTodo : l10n.editTodo),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                  return l10n.titleRequired;
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
            Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                print('当前选中的分类: ${_selectedCategory?.toJson()}');
                print(
                    '可选分类列表: ${provider.categories.map((c) => c.toJson()).toList()}');

                return DropdownButtonFormField<Category?>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.noCategory),
                    ),
                    ...provider.categories.map((category) {
                      if (_selectedCategory?.id == category.id) {
                        _selectedCategory = category;
                      }
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            if (category.color != null)
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                      category.color!.replaceFirst('#', 'FF'),
                                      radix: 16)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(category.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                );
              },
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
                print('当前优先级: $_priority');
                print('选择的优先级: $value');
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
      categoryId: _selectedCategory?.id,
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
