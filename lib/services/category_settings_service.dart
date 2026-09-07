import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý danh sách nhóm chi tiêu (tag) bị người dùng ẩn/xóa khỏi gợi ý —
/// áp dụng cho cả tag preset ([presetTransactionCategories]) lẫn tag tự gõ
/// đã từng dùng. Lưu bằng SharedPreferences vì đây chỉ là tùy chọn hiển thị
/// (không phải dữ liệu giao dịch), không cần đến Drift/SQLite.
class CategorySettingsService {
  const CategorySettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'hidden_transaction_categories';

  Set<String> getHiddenCategories() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<String>().toSet();
  }

  Future<void> hideCategory(String category) async {
    final hidden = getHiddenCategories()..add(category);
    await _prefs.setString(_key, jsonEncode(hidden.toList()));
  }
}
