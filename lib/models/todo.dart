import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'reminder.dart';

part 'todo.g.dart';

/// 待办事项模型
@JsonSerializable()
class Todo {
  /// 待办事项ID
  final int? id;

  /// 标题
  final String title;

  /// 描述
  final String? description;

  /// 是否已完成
  final bool completed;

  /// 优先级（low/medium/high）
  final String priority;

  /// 分类ID
  final int? categoryId;

  /// 所属分类
  final Category? category;

  /// 相关提醒列表
  final List<Reminder>? reminders;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 截止日期
  final DateTime? dueDate;

  /// 完成时间
  final DateTime? completedAt;

  /// 是否为离线数据
  final bool isOffline;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.priority = 'medium',
    this.categoryId,
    this.category,
    this.reminders,
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.isOffline = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      categoryId: json['categoryId'] as int?,
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isOffline: json['isOffline'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'completed': completed,
        'priority': priority,
        'categoryId': categoryId,
        'category': category?.toJson(),
        'reminders': reminders?.map((r) => r.toJson()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isOffline': isOffline,
      };

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    String? priority,
    int? categoryId,
    Category? category,
    List<Reminder>? reminders,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    bool? isOffline,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool hasActiveReminder() {
    return reminders
            ?.any((reminder) => reminder.remindAt.isAfter(DateTime.now())) ??
        false;
  }
}
