import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/category_settings_service.dart';

/// Instance [SharedPreferences] đã khởi tạo sẵn ở `main()` (bất đồng bộ) và
/// truyền vào qua override — provider gốc chỉ throw để báo lỗi rõ ràng nếu
/// lỡ quên override (ví dụ trong test).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider phải được override ở main() hoặc test',
  );
});

final categorySettingsServiceProvider = Provider<CategorySettingsService>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CategorySettingsService(prefs);
});
