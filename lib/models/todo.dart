import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'reminder.dart';

part 'todo.g.dart';

@JsonSerializable()
class Todo {
  final int? id;
  final String title;
  final String? description;
  final bool completed;
  final String priority;
  final int? categoryId;
  final Category? category;
  final List<Reminder>? reminders;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.completed = false,
    required this.priority,
    this.categoryId,
    this.category,
    this.reminders,
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    String? priority,
    int? categoryId,
    Category? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
