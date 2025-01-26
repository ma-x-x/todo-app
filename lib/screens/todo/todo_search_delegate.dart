import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter_provider.dart';
import '../../providers/todo_provider.dart';

class TodoSearchDelegate extends SearchDelegate<String> {
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

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    context.read<FilterProvider>().setSearchQuery(query);
    return Container();
  }

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
