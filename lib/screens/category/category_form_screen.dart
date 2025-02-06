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
              label: '名称',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '请输入分类名称';
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
              child: BlockPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                itemBuilder: (color, isCurrentColor, onTap) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isCurrentColor ? Colors.blue : Colors.grey.shade300,
                        width: isCurrentColor ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
