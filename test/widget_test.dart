import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/main.dart';
import 'package:thu_chi/providers/category_settings_providers.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/providers/notification_providers.dart';

import 'helpers/fake_native_notification_service.dart';

void main() {
  testWidgets('App boots and shows the bottom navigation tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Dùng DB in-memory thay vì mở file thật qua path_provider, và
          // native service giả thay vì MethodChannel/EventChannel thật —
          // không có platform channel nào trong môi trường test.
          appDatabaseProvider.overrideWithValue(AppDatabase.forTesting(NativeDatabase.memory())),
          nativeNotificationServiceProvider.overrideWithValue(FakeNativeNotificationService()),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ThuChiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tổng quan'), findsWidgets);
    expect(find.text('Giao dịch'), findsWidgets);
    expect(find.text('Hoạt động'), findsWidgets);
    expect(find.text('Thành tựu'), findsWidgets);
    expect(find.text('Cài đặt'), findsWidgets);
  });
}
