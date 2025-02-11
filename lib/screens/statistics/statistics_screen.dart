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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<TodoProvider, CategoryProvider>(
        builder: (context, todoProvider, categoryProvider, child) {
          final statistics =
              StatisticsService().calculateStatistics(todoProvider.todos);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.overview,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStatRow(
                        context,
                        l10n.totalTodos,
                        statistics.totalTodos.toString(),
                        Icons.format_list_bulleted,
                        theme.colorScheme.primary,
                      ),
                      _buildStatRow(
                        context,
                        l10n.completedTodos,
                        statistics.completedTodos.toString(),
                        Icons.check_circle_outline,
                        theme.colorScheme.tertiary,
                      ),
                      _buildStatRow(
                        context,
                        l10n.activeTodos,
                        statistics.activeTodos.toString(),
                        Icons.pending_outlined,
                        theme.colorScheme.error,
                      ),
                      _buildStatRow(
                        context,
                        l10n.completionRate,
                        '${statistics.completionRate.toStringAsFixed(1)}%',
                        Icons.percent,
                        theme.colorScheme.secondary,
                      ),
                      _buildStatRow(
                        context,
                        l10n.averageCompletionTime,
                        '${statistics.averageCompletionTime.toStringAsFixed(1)} ${l10n.hours}',
                        Icons.timer_outlined,
                        theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.todosByPriority,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections:
                                _buildPrioritySections(context, statistics),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            startDegreeOffset: -90,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPriorityLegend(context, theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.todosByCategory,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: statistics.todosByCategory.values
                                .fold(0,
                                    (max, value) => value > max ? value : max)
                                .toDouble(),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: theme.colorScheme.outlineVariant,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: _buildCategoryTitles(
                                context, statistics, categoryProvider, theme),
                            borderData: FlBorderData(show: false),
                            barGroups: _buildCategoryGroups(
                                statistics, theme, categoryProvider),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.completionTrend,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _buildTrendSpots(statistics),
                                isCurved: true,
                                color: theme.colorScheme.primary,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, bar, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: theme.colorScheme.primary,
                                      strokeWidth: 2,
                                      strokeColor: theme.colorScheme.surface,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: theme.colorScheme.primary
                                      .withAlpha((0.1 * 255).round()),
                                ),
                              ),
                            ],
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: theme.colorScheme.outlineVariant,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: _buildTrendTitles(context, theme),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建优先级分布饼图
  List<PieChartSectionData> _buildPrioritySections(
      BuildContext context, TodoStatistics statistics) {
    // 定义优先级对应的颜色
    final priorityColors = {
      'low': Colors.green,
      'medium': Colors.orange,
      'high': Colors.red,
    };

    // 转换数据为饼图段
    return statistics.todosByPriority.entries.map((entry) {
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
  }

  /// 构建优先级分布图例
  Widget _buildPriorityLegend(BuildContext context, ThemeData theme) {
    // 定义优先级对应的颜色
    final priorityColors = {
      'low': Colors.green,
      'medium': Colors.orange,
      'high': Colors.red,
    };

    // 添加图例
    return Wrap(
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
    );
  }

  /// 构建分类分布柱状图
  List<BarChartGroupData> _buildCategoryGroups(TodoStatistics statistics,
      ThemeData theme, CategoryProvider categoryProvider) {
    return statistics.todosByCategory.entries.map((entry) {
      final category = categoryProvider.categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => categoryProvider.categories.first,
      );
      final color = category.color != null
          ? Color(int.parse(category.color!.replaceFirst('#', 'FF'), radix: 16))
          : theme.colorScheme.primary;

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: color,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  /// 构建分类分布柱状图标题
  FlTitlesData _buildCategoryTitles(
      BuildContext context,
      TodoStatistics statistics,
      CategoryProvider categoryProvider,
      ThemeData theme) {
    // 获取分类名称映射
    final categoryNames = {
      for (var category in categoryProvider.categories)
        category.id: category.name
    };

    return FlTitlesData(
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
    );
  }

  /// 构建完成趋势折线图
  List<FlSpot> _buildTrendSpots(TodoStatistics statistics) {
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
    return dates.map((date) {
      return FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        statistics.completionByDate[date]?.toDouble() ?? 0,
      );
    }).toList();
  }

  /// 构建完成趋势折线图标题
  FlTitlesData _buildTrendTitles(BuildContext context, ThemeData theme) {
    return FlTitlesData(
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
    );
  }
}
