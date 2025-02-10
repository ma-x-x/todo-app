import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._();
  factory OfflineManager() => _instance;

  late SharedPreferences _prefs;
  final _pendingChanges = <String, List<Map<String, dynamic>>>{};

  OfflineManager._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPendingChanges();
  }

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

  Future<void> _savePendingChanges() async {
    await _prefs.setString('pending_changes', jsonEncode(_pendingChanges));
  }

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
