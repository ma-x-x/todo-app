import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/filter_provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/todo_item_card.dart';
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

class _TodoListScreenState extends State<TodoListScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<void> _loadDataFuture;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
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
              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: todos.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                cacheExtent: 500,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return RepaintBoundary(
                    child: TodoItemCard(
                      key: ValueKey(todo.id),
                      todo: todo,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'todo_add_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TodoFormScreen()),
          );
        },
        tooltip: l10n.newTodo,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
