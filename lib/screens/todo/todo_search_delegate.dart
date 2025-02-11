import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter_provider.dart';
import '../../providers/todo_provider.dart';

/// 待办事项搜索代理
/// 实现待办事项的搜索功能，支持按标题搜索
/// 提供实时搜索建议和结果显示
class TodoSearchDelegate extends SearchDelegate<String> {
  /// 构建操作按钮（清除输入）
  /// [context] 构建上下文
  /// 返回包含清除按钮的操作列表
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  /// 构建前导按钮（返回按钮）
  /// [context] 构建上下文
  /// 返回返回按钮组件
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  /// 构建搜索结果
  /// [context] 构建上下文
  /// 设置搜索查询并返回空容器
  @override
  Widget buildResults(BuildContext context) {
    context.read<FilterProvider>().setSearchQuery(query);
    return Container();
  }

  /// 构建搜索建议
  /// [context] 构建上下文
  /// 返回匹配当前输入的待办事项列表
  @override
  Widget buildSuggestions(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final todos = todoProvider.todos
        .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          onTap: () {
            query = todo.title;
            showResults(context);
          },
        );
      },
    );
  }
}
