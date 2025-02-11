import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/custom_text_field.dart';

/// 分类表单页面
/// 用于创建新的分类或编辑现有分类
/// 包含分类名称和颜色选择功能
class CategoryFormScreen extends StatefulWidget {
  /// 要编辑的分类，如果为null则表示创建新分类
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  /// 表单全局键，用于验证表单
  final _formKey = GlobalKey<FormState>();

  /// 分类名称输入控制器
  late TextEditingController _nameController;

  /// 选中的颜色
  Color _selectedColor = Colors.blue;

  /// 是否正在加载
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    if (widget.category?.color != null) {
      _selectedColor = Color(
        int.parse(widget.category!.color!.replaceFirst('#', 'FF'), radix: 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? l10n.newCategory : l10n.editCategory,
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CustomTextField(
              controller: _nameController,
              label: l10n.categoryName,
              obscureText: false,
              prefixIcon: const Icon(Icons.category_outlined),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return l10n.errorRequired(l10n.categoryName);
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Text(
              l10n.categoryColor,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _selectedColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _nameController.text.isEmpty
                                  ? "A"
                                  : _nameController.text[0].toUpperCase(),
                              style: TextStyle(
                                color: _selectedColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.isEmpty
                                    ? l10n.categoryName
                                    : _nameController.text,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BlockPicker(
                      pickerColor: _selectedColor,
                      onColorChanged: (color) {
                        setState(() => _selectedColor = color);
                      },
                      itemBuilder: (color, isCurrentColor, onTap) => Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrentColor
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            if (isCurrentColor)
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(l10n.save),
          ),
        ),
      ),
    );
  }

  /// 提交表单
  /// 创建或更新分类
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final colorString =
          '#${_selectedColor.value.toRadixString(16).substring(2)}';
      final provider = context.read<CategoryProvider>();

      if (widget.category == null) {
        await provider.createCategory(
          _nameController.text,
          color: colorString,
        );
      } else {
        final updatedCategory = Category(
          id: widget.category!.id,
          name: _nameController.text,
          color: colorString,
          createdAt: widget.category!.createdAt,
          updatedAt: DateTime.now(),
        );
        await provider.updateCategory(updatedCategory);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
