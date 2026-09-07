import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/active_session.dart';
import '../models/activity_definition.dart';
import '../models/activity_session.dart';

/// Lưu trữ tạm thời (trong lúc thiết kế phần "Hoạt động" còn thay đổi) bằng
/// SharedPreferences — 3 khối JSON: [getActivities]/[saveActivities],
/// [getSessions]/[addSession], [getActiveSession]/[setActiveSession]. Khi
/// thiết kế ổn định sẽ chuyển sang bảng Drift thật.
class ActivityStorageService {
  const ActivityStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _activitiesKey = 'activities';
  static const _sessionsKey = 'activity_sessions';
  static const _activeSessionKey = 'active_session';

  List<ActivityDefinition> getActivities() {
    final raw = _prefs.getString(_activitiesKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => ActivityDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveActivities(List<ActivityDefinition> activities) async {
    final encoded = jsonEncode(activities.map((a) => a.toJson()).toList());
    await _prefs.setString(_activitiesKey, encoded);
  }

  List<ActivitySession> getSessions() {
    final raw = _prefs.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => ActivitySession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSession(ActivitySession session) async {
    final sessions = getSessions()..add(session);
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_sessionsKey, encoded);
  }

  /// Xóa 1 session cụ thể (so khớp bằng [Equatable]) — dùng khi bỏ tick 1
  /// hoạt động checkbox.
  Future<void> removeSession(ActivitySession session) async {
    final sessions = getSessions()..remove(session);
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_sessionsKey, encoded);
  }

  ActiveSession? getActiveSession() {
    final raw = _prefs.getString(_activeSessionKey);
    if (raw == null || raw.isEmpty) return null;
    return ActiveSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> setActiveSession(ActiveSession? session) async {
    if (session == null) {
      await _prefs.remove(_activeSessionKey);
      return;
    }
    await _prefs.setString(_activeSessionKey, jsonEncode(session.toJson()));
  }
}
