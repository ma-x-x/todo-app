import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/filter_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/todo_filter.dart';
import '../../models/category.dart';

class TodoFilterScreen extends StatelessWidget {
  const TodoFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.filters),
        actions: [
          TextButton(
            onPressed: () {
              context.read<FilterProvider>().clearFilters();
            },
            child: Text(AppLocalizations.of(context)!.clearFilters),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.status),
          ),
          Consumer<FilterProvider>(
            builder: (context, provider, child) {
              return Column(
                children: TodoFilter.values.map((filter) {
                  return RadioListTile<TodoFilter>(
                    title: Text(_getFilterName(context, filter)),
                    value: filter,
                    groupValue: provider.filter,
                    onChanged: (value) {
                      if (value != null) {
                        provider.setFilter(value);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.category),
          ),
          Consumer2<FilterProvider, CategoryProvider>(
            builder: (context, filterProvider, categoryProvider, child) {
              return Column(
                children: [
                  RadioListTile<Category?>(
                    title: Text(AppLocalizations.of(context)!.all),
                    value: null,
                    groupValue: filterProvider.selectedCategory,
                    onChanged: (value) {
                      filterProvider.setSelectedCategory(value);
                    },
                  ),
                  ...categoryProvider.categories.map((category) {
                    return RadioListTile<Category>(
                      title: Text(category.name),
                      value: category,
                      groupValue: filterProvider.selectedCategory,
                      onChanged: (value) {
                        filterProvider.setSelectedCategory(value);
                      },
                    );
                  }).toList(),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.priority),
          ),
          Consumer<FilterProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  RadioListTile<String?>(
                    title: Text(AppLocalizations.of(context)!.all),
                    value: null,
                    groupValue: provider.selectedPriority,
                    onChanged: (value) {
                      provider.setSelectedPriority(value);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(AppLocalizations.of(context)!.priorityLow),
                    value: 'low',
                    groupValue: provider.selectedPriority,
                    onChanged: (value) {
                      provider.setSelectedPriority(value);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(AppLocalizations.of(context)!.priorityMedium),
                    value: 'medium',
                    groupValue: provider.selectedPriority,
                    onChanged: (value) {
                      provider.setSelectedPriority(value);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(AppLocalizations.of(context)!.priorityHigh),
                    value: 'high',
                    groupValue: provider.selectedPriority,
                    onChanged: (value) {
                      provider.setSelectedPriority(value);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getFilterName(BuildContext context, TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return AppLocalizations.of(context)!.all;
      case TodoFilter.active:
        return AppLocalizations.of(context)!.active;
      case TodoFilter.completed:
        return AppLocalizations.of(context)!.completed;
    }
  }
} 