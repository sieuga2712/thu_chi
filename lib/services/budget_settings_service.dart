import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_config.dart';

/// Lưu cấu hình ngân sách tổng bằng SharedPreferences — chỉ là một tùy chọn
/// người dùng đặt (không phải dữ liệu giao dịch), không cần Drift/SQLite.
class BudgetSettingsService {
  const BudgetSettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'budget_config';

  BudgetConfig? getBudget() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    return BudgetConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> setBudget(BudgetConfig config) async {
    await _prefs.setString(_key, jsonEncode(config.toJson()));
  }

  Future<void> clearBudget() async {
    await _prefs.remove(_key);
  }
}
