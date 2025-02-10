import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/category.dart';
import '../models/todo.dart';

class ExportService {
  /// 导出待办事项为CSV文件
  Future<String> exportToCsv({
    required List<Todo> todos,
    required Map<int, Category> categories,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Web平台暂不支持导出功能');
    }
    final csvData = [
      // CSV 表头
      ['标题', '描述', '分类', '优先级', '创建时间', '截止时间', '完成时间', '状态'],
      // CSV 数据行
      ...todos.map((todo) => [
            todo.title,
            todo.description ?? '',
            categories[todo.categoryId]?.name ?? '',
            todo.priority,
            todo.createdAt?.toIso8601String() ?? '',
            todo.dueDate?.toIso8601String() ?? '',
            todo.completedAt?.toIso8601String() ?? '',
            todo.completed ? '已完成' : '进行中',
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/todos_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csvString);
    return file.path;
  }

  /// 导出待办事项为PDF文件
  Future<String> exportToPdf({
    required List<Todo> todos,
    required Map<int, Category> categories,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Web平台暂不支持导出功能');
    }

    print('开始创建PDF文档...');
    final pdf = pw.Document();

    try {
      print('添加标题页...');
      // 添加标题页
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    '待办事项列表',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '导出时间：${DateTime.now().toString()}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      print('添加待办事项列表页...');
      // 添加待办事项列表页
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('待办事项'),
                ),
                pw.TableHelper.fromTextArray(
                  headers: ['标题', '分类', '优先级', '状态'],
                  data: todos
                      .map((todo) => [
                            todo.title,
                            categories[todo.categoryId]?.name ?? '',
                            todo.priority,
                            todo.completed ? '已完成' : '进行中',
                          ])
                      .toList(),
                ),
              ],
            );
          },
        ),
      );

      print('添加统计信息页...');
      // 添加统计信息页
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            final completedTodos = todos.where((todo) => todo.completed).length;
            final completionRate =
                todos.isEmpty ? 0.0 : (completedTodos / todos.length * 100);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('统计信息'),
                ),
                pw.Paragraph(
                  text: '总任务数：${todos.length}',
                ),
                pw.Paragraph(
                  text: '已完成：$completedTodos',
                ),
                pw.Paragraph(
                  text: '进行中：${todos.length - completedTodos}',
                ),
                pw.Paragraph(
                  text: '完成率：${completionRate.toStringAsFixed(1)}%',
                ),
              ],
            );
          },
        ),
      );

      print('获取应用文档目录...');
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/todos_${DateTime.now().millisecondsSinceEpoch}.pdf';

      print('保存PDF文件...');
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print('PDF文件已保存: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      print('PDF生成失败: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
    }
  }
}
