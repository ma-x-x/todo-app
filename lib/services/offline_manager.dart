import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 离线管理器
/// 管理离线状态下的数据变更，实现离线同步功能
class OfflineManager {
  static final OfflineManager _instance = OfflineManager._();
  factory OfflineManager() => _instance;

  late SharedPreferences _prefs;
  final _pendingChanges = <String, List<Map<String, dynamic>>>{};

  OfflineManager._();

  /// 初始化离线管理器
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPendingChanges();
  }

  /// 加载待处理的变更
  void _loadPendingChanges() {
    final json = _prefs.getString('pending_changes');
    if (json != null) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      _pendingChanges.clear();
      data.forEach((key, value) {
        _pendingChanges[key] = (value as List).cast<Map<String, dynamic>>();
      });
    }
  }

  /// 保存待处理的变更
  Future<void> _savePendingChanges() async {
    await _prefs.setString('pending_changes', jsonEncode(_pendingChanges));
  }

  /// 添加待处理的变更
  ///
  /// 参数:
  /// - type: 变更类型
  /// - change: 变更内容
  void addPendingChange(String type, Map<String, dynamic> change) {
    _pendingChanges.putIfAbsent(type, () => []).add(change);
    _savePendingChanges();
  }

  List<Map<String, dynamic>> getPendingChanges(String type) {
    return _pendingChanges[type] ?? [];
  }

  void clearPendingChanges(String type) {
    _pendingChanges.remove(type);
    _savePendingChanges();
  }
}
