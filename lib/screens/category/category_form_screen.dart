import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/custom_text_field.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    if (widget.category?.color != null) {
      _selectedColor = Color(
        int.parse(widget.category!.color!.substring(1, 7), radix: 16) + 0xFF000000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? '新建分类' : '编辑分类'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              label: '分类名称',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '请输入分类名称';
                }
                if (value!.length > 32) {
                  return '分类名称不能超过32个字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('选择颜色：'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  BlockPicker(
                    pickerColor: _selectedColor,
                    onColorChanged: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('保存'),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final colorString = '#${_selectedColor.value.toRadixString(16).substring(2)}';
      
      if (widget.category == null) {
        await context.read<CategoryProvider>().createCategory(
          _nameController.text,
          colorString,
        );
      } else {
        final updatedCategory = Category(
          id: widget.category!.id,
          name: _nameController.text,
          color: colorString,
          userId: widget.category!.userId,
          createdAt: widget.category!.createdAt,
          updatedAt: DateTime.now(),
        );
        await context.read<CategoryProvider>().updateCategory(updatedCategory);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
} 