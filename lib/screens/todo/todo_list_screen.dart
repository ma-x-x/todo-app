import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/filter_provider.dart';
import '../../models/todo_filter.dart';
import '../../widgets/todo_item.dart';
import 'todo_search_delegate.dart';
import 'todo_filter_screen.dart';
import 'todo_form_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.todoList),
        actions: [
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
            itemCount: todos.length,
            itemBuilder: (context, index) {
              return TodoItem(todo: todos[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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