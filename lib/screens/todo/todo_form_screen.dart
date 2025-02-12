import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/todo.dart';
import '../../providers/category_provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/common/custom_text_field.dart';

/// 待办事项表单页面
/// 用于创建新的待办事项或编辑现有待办事项
/// 包含标题、描述、分类、优先级等字段的输入
class TodoFormScreen extends StatefulWidget {
  /// 要编辑的待办事项，如果为null则表示创建新待办事项
  final Todo? todo;

  const TodoFormScreen({super.key, this.todo});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  /// 表单的全局键，用于验证表单
  final _formKey = GlobalKey<FormState>();

  /// 标题输入控制器
  final _titleController = TextEditingController();

  /// 描述输入控制器
  final _descriptionController = TextEditingController();

  /// 选中的分类
  Category? _selectedCategory;

  /// 选中的优先级
  String _priority = 'medium';

  /// 移除 _initFuture
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 使用 Future.microtask 来避免在 initState 中直接调用 setState
    Future.microtask(() => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      final categoryProvider = context.read<CategoryProvider>();
      final todoProvider = context.read<TodoProvider>();

      // 1. 加载分类数据
      if (!categoryProvider.isInitialized) {
        await categoryProvider.loadCategories();
      }

      // 2. 如果是编辑模式，加载待办详情
      if (widget.todo != null) {
        final todo = await todoProvider.getTodoDetail(widget.todo!.id!);
        if (!mounted) return;

        _titleController.text = todo.title;
        _descriptionController.text = todo.description ?? '';
        _priority = todo.priority;

        if (todo.categoryId != null) {
          _selectedCategory = categoryProvider.categories
              .firstWhereOrNull((c) => c.id == todo.categoryId);
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? '新建待办' : '编辑待办'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadInitialData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleField(context),
            const SizedBox(height: 20),
            _buildDescriptionField(context),
            const SizedBox(height: 24),
            _buildCategoryField(context),
            const SizedBox(height: 20),
            _buildPriorityField(context),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submit,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomTextField(
      controller: _titleController,
      label: l10n.title,
      prefixIcon: const Icon(Icons.title_outlined),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return l10n.titleRequired;
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomTextField(
      controller: _descriptionController,
      label: l10n.description,
      prefixIcon: const Icon(Icons.description_outlined),
      maxLines: 3,
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        return DropdownButtonFormField<Category?>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: l10n.category,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.category_outlined),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(l10n.noCategory),
            ),
            ...provider.categories.map((category) {
              final color = category.color != null
                  ? Color(int.parse(category.color!.replaceFirst('#', 'FF'),
                      radix: 16))
                  : theme.colorScheme.primary;
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                    ),
                    Text(category.name),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) => setState(() => _selectedCategory = value),
        );
      },
    );
  }

  Widget _buildPriorityField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DropdownButtonFormField<String>(
      value: _priority,
      decoration: InputDecoration(
        labelText: l10n.priority,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.flag_outlined),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      items: [
        _buildPriorityItem('low', Icons.arrow_downward, l10n.priorityLow,
            theme.colorScheme.tertiary, theme),
        _buildPriorityItem('medium', Icons.remove, l10n.priorityMedium,
            theme.colorScheme.primary, theme),
        _buildPriorityItem('high', Icons.priority_high, l10n.priorityHigh,
            theme.colorScheme.error, theme),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _priority = value);
        }
      },
    );
  }

  DropdownMenuItem<String> _buildPriorityItem(
      String value, IconData icon, String label, Color color, ThemeData theme) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  /// 提交表单
  /// 创建或更新待办事项
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

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

      final todoProvider = context.read<TodoProvider>();
      if (widget.todo == null) {
        await todoProvider.createTodo(todo, _selectedCategory);
      } else {
        await todoProvider.updateTodo(todo, _selectedCategory);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
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
