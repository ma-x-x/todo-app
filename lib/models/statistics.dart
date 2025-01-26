/// 待办事项统计数据模型
class TodoStatistics {
  /// 总任务数
  final int totalTodos;
  
  /// 已完成的任务数
  final int completedTodos;
  
  /// 进行中的任务数
  final int activeTodos;
  
  /// 按优先级统计的任务数量
  /// key: 优先级(low/medium/high), value: 该优先级的任务数量
  final Map<String, int> todosByPriority;
  
  /// 按分类统计的任务数量
  /// key: 分类ID, value: 该分类下的任务数量
  final Map<int, int> todosByCategory;
  
  /// 按完成日期统计的任务数量
  /// key: 完成日期, value: 当天完成的任务数量
  final Map<DateTime, int> completionByDate;
  
  /// 任务完成率（百分比）
  final double completionRate;
  
  /// 平均完成时间（小时）
  final double averageCompletionTime;

  TodoStatistics({
    required this.totalTodos,
    required this.completedTodos,
    required this.activeTodos,
    required this.todosByPriority,
    required this.todosByCategory,
    required this.completionByDate,
    required this.completionRate,
    required this.averageCompletionTime,
  });
} 