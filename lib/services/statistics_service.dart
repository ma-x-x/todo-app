import 'package:collection/collection.dart';

import '../models/statistics.dart';
import '../models/todo.dart';

/// 统计服务类，用于计算各种统计数据
class StatisticsService {
  /// 计算待办事项的统计数据
  TodoStatistics calculateStatistics(List<Todo> todos) {
    final now = DateTime.now();

    // 计算基本数量统计
    final totalTodos = todos.length;
    final completedTodos = todos.where((todo) => todo.completed).length;
    final activeTodos = totalTodos - completedTodos;

    // 按优先级分组统计
    // 使用 groupBy 函数将任务按优先级分组，然后计算每个优先级的任务数量
    final todosByPriority = groupBy(todos, (Todo todo) => todo.priority)
        .map((key, value) => MapEntry(key, value.length));

    // 按分类分组统计 - 过滤掉没有分类ID的待办事项
    final todosByCategory = groupBy(
      todos.where((todo) => todo.categoryId != null),
      (Todo todo) => todo.categoryId!, // 使用非空断言，因为我们已经过滤掉了空值
    ).map((key, value) => MapEntry(key, value.length));

    // 按完成日期分组统计
    // 只统计已完成且有完成时间的任务
    final completionByDate = groupBy(
      todos.where((todo) => todo.completed && todo.completedAt != null),
      (Todo todo) => DateTime(
        todo.completedAt!.year,
        todo.completedAt!.month,
        todo.completedAt!.day,
      ),
    ).map((key, value) => MapEntry(key, value.length));

    // 计算完成率（完成数/总数）
    final completionRate =
        totalTodos > 0 ? (completedTodos / totalTodos * 100) : 0.0;

    // 计算平均完成时间
    // 只计算已完成且有创建时间和完成时间的任务
    final completedWithTimes = todos.where(
      (todo) =>
          todo.completed && todo.completedAt != null && todo.createdAt != null,
    );

    // 计算所有任务的完成时间的平均值
    final averageCompletionTime = completedWithTimes.isEmpty
        ? 0.0
        : completedWithTimes
            .map(
                (todo) => todo.completedAt!.difference(todo.createdAt!).inHours)
            .average;

    return TodoStatistics(
      totalTodos: totalTodos,
      completedTodos: completedTodos,
      activeTodos: activeTodos,
      todosByPriority: todosByPriority,
      todosByCategory: todosByCategory,
      completionByDate: completionByDate,
      completionRate: completionRate,
      averageCompletionTime: averageCompletionTime,
    );
  }
}
