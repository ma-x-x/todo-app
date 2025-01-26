import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/statistics.dart';
import '../../providers/category_provider.dart';
import '../../providers/todo_provider.dart';
import '../../services/statistics_service.dart';

/// 统计分析页面
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statistics),
      ),
      // 使用 Consumer2 同时监听待办事项和分类的变化
      body: Consumer2<TodoProvider, CategoryProvider>(
        builder: (context, todoProvider, categoryProvider, child) {
          // 计算统计数据
          final statistics =
              StatisticsService().calculateStatistics(todoProvider.todos);

          // 使用 ListView 显示多个统计卡片
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverviewCard(context, statistics),
              const SizedBox(height: 16),
              _buildPriorityChart(context, statistics),
              const SizedBox(height: 16),
              _buildCategoryChart(context, statistics, categoryProvider),
              const SizedBox(height: 16),
              _buildCompletionTrendChart(context, statistics),
            ],
          );
        },
      ),
    );
  }

  /// 构建概览卡片，显示基本统计数据
  Widget _buildOverviewCard(BuildContext context, TodoStatistics statistics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.overview,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // 显示各项统计数据
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.totalTodos,
              statistics.totalTodos.toString(),
            ),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.completedTodos,
              statistics.completedTodos.toString(),
            ),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.activeTodos,
              statistics.activeTodos.toString(),
            ),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.completionRate,
              '${statistics.completionRate.toStringAsFixed(1)}%',
            ),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.averageCompletionTime,
              '${statistics.averageCompletionTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计数据行，显示标签和值
  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// 构建优先级分布饼图
  Widget _buildPriorityChart(BuildContext context, TodoStatistics statistics) {
    // 定义优先级对应的颜色
    final priorityColors = {
      'low': Colors.green,
      'medium': Colors.orange,
      'high': Colors.red,
    };

    // 转换数据为饼图段
    final sections = statistics.todosByPriority.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${AppLocalizations.of(context)!.priority}${entry.value}',
        color: priorityColors[entry.key] ?? Colors.grey,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.todosByPriority,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 添加图例
            Wrap(
              spacing: 16,
              children: priorityColors.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: entry.value,
                    ),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.priority + entry.key),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分类分布柱状图
  Widget _buildCategoryChart(
    BuildContext context,
    TodoStatistics statistics,
    CategoryProvider categoryProvider,
  ) {
    // 获取分类名称映射
    final categoryNames = {
      for (var category in categoryProvider.categories)
        category.id: category.name
    };

    // 转换数据为柱状图数据
    final barGroups = statistics.todosByCategory.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.todosByCategory,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: statistics.todosByCategory.values
                      .fold(0, (max, value) => value > max ? value : max)
                      .toDouble(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              categoryNames[value.toInt()] ?? '',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建完成趋势折线图
  Widget _buildCompletionTrendChart(
    BuildContext context,
    TodoStatistics statistics,
  ) {
    // 获取最近7天的数据
    final now = DateTime.now();
    final dates = List.generate(7, (index) {
      return DateTime(
        now.year,
        now.month,
        now.day - index,
      );
    }).reversed.toList();

    // 转换数据为折线图点
    final spots = dates.map((date) {
      return FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        statistics.completionByDate[date]?.toDouble() ?? 0,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.completionTrend,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
