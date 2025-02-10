import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/todo_filter.dart';
import '../../providers/filter_provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/todo_item.dart';
import 'todo_filter_screen.dart';
import 'todo_form_screen.dart';
import 'todo_search_delegate.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.todoList),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TodoProvider>().loadTodos();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TodoSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TodoFilterScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<TodoProvider, FilterProvider>(
        builder: (context, todoProvider, filterProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (todoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${todoProvider.error}'),
                  ElevatedButton(
                    onPressed: () => todoProvider.loadTodos(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final todos = todoProvider.todos.where((todo) {
            // 应用搜索过滤
            if (filterProvider.searchQuery.isNotEmpty) {
              final query = filterProvider.searchQuery.toLowerCase();
              if (!todo.title.toLowerCase().contains(query) &&
                  !(todo.description?.toLowerCase().contains(query) ?? false)) {
                return false;
              }
            }

            // 应用状态过滤
            switch (filterProvider.filter) {
              case TodoFilter.active:
                if (todo.completed) return false;
                break;
              case TodoFilter.completed:
                if (!todo.completed) return false;
                break;
              default:
                break;
            }

            // 应用分类过滤
            if (filterProvider.selectedCategory != null &&
                todo.categoryId != filterProvider.selectedCategory!.id) {
              return false;
            }

            // 应用优先级过滤
            if (filterProvider.selectedPriority != null &&
                todo.priority != filterProvider.selectedPriority) {
              return false;
            }

            return true;
          }).toList();

          if (todos.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noTodos),
            );
          }

          return ListView.builder(
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            itemCount: todos.length,
            itemBuilder: (context, index) => TodoItem(
              key: ValueKey(todos[index].id),
              todo: todos[index],
            ),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
