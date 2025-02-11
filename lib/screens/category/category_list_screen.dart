import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import 'category_form_screen.dart';

/// 分类列表页面
/// 显示所有分类，支持添加、编辑和删除分类
/// 每个分类显示名称和颜色标识
class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = Future(() async {
      if (!mounted) return;
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      await categoryProvider.ensureInitialized();
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.loadCategories();
  }

  /// 解析颜色字符串
  /// [colorString] 颜色的十六进制字符串
  /// 返回解析后的Color对象，解析失败返回null
  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      return Color(int.parse(colorString.replaceFirst('#', 'FF'), radix: 16));
    } catch (e) {
      debugPrint('Error parsing color: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: _refresh,
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
                      l10n.loadingError(snapshot.error.toString()),
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

          final categoryProvider = Provider.of<CategoryProvider>(context);

          if (categoryProvider.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: theme.colorScheme.primary
                          .withAlpha((0.5 * 255).round()),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noCategories,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noCategoriesHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              final categoryColor = _parseColor(category.color);

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryFormScreen(category: category),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color:
                                categoryColor?.withAlpha((0.15 * 255).round()),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: categoryColor ?? theme.colorScheme.outline,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (categoryColor ?? theme.colorScheme.primary)
                                        .withAlpha((0.1 * 255).round()),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              category.name.characters.first.toUpperCase(),
                              style: TextStyle(
                                color:
                                    categoryColor ?? theme.colorScheme.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.color?.toUpperCase() ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.outlined(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          style: IconButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(
                              color: theme.colorScheme.error
                                  .withAlpha((0.2 * 255).round()),
                            ),
                          ),
                          tooltip: l10n.delete,
                          onPressed: () => _confirmDelete(context, category.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryFormScreen()),
          );
        },
        tooltip: l10n.newCategory,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 显示删除确认对话框
  /// [context] 构建上下文
  /// [id] 要删除的分类ID
  Future<void> _confirmDelete(BuildContext context, int id) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteCategory),
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
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);
        await categoryProvider.deleteCategory(id);
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
