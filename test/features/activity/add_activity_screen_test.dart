import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/features/activity/presentation/screens/add_activity_screen.dart';
import 'package:thu_chi/models/activity_kind.dart';
import 'package:thu_chi/providers/category_settings_providers.dart';
import 'package:thu_chi/services/activity_storage_service.dart';

void main() {
  late SharedPreferences prefs;
  late ActivityStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = ActivityStorageService(prefs);
  });

  Widget buildApp(ActivityKind kind) {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(home: AddActivityScreen(kind: kind)),
    );
  }

  group('kind = checkbox', () {
    testWidgets('lưu hoạt động Hằng ngày: đủ icon mặc định, không cần nhập số buổi', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(ActivityKind.checkbox));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Chuẩn bị đồ đạc');
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu hoạt động'));
      await tester.pumpAndSettle();

      final saved = storage.getActivities();
      expect(saved, hasLength(1));
      expect(saved.single.name, 'Chuẩn bị đồ đạc');
      expect(saved.single.kind, ActivityKind.checkbox);
      expect(saved.single.icon, isNotNull);
    });

    testWidgets('chọn Theo tuần rồi nhập số buổi hợp lệ: lưu đúng weeklyGoalCount', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(ActivityKind.checkbox));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Tập gym');
      await tester.tap(find.text('Theo tuần'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('weekly_goal_field')), '4');
      final saveButton = find.widgetWithText(FilledButton, 'Lưu hoạt động');
      await tester.dragUntilVisible(
        saveButton,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final saved = storage.getActivities().single;
      expect(saved.weeklyGoalCount, 4);
    });

    testWidgets('chọn Theo tuần nhưng nhập số buổi > 7: báo lỗi, không lưu', (tester) async {
      await tester.pumpWidget(buildApp(ActivityKind.checkbox));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Tập gym');
      await tester.tap(find.text('Theo tuần'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('weekly_goal_field')), '9');
      final saveButton = find.widgetWithText(FilledButton, 'Lưu hoạt động');
      await tester.dragUntilVisible(
        saveButton,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(storage.getActivities(), isEmpty);
      expect(find.textContaining('Nhập số buổi mục tiêu'), findsOneWidget);
    });
  });

  group('kind = timed', () {
    testWidgets('không hiện lựa chọn icon/tần suất, form giữ nguyên như trước', (tester) async {
      await tester.pumpWidget(buildApp(ActivityKind.timed));
      await tester.pumpAndSettle();

      expect(find.text('Lĩnh vực'), findsOneWidget);
      expect(find.text('Kiểu đồng hồ'), findsOneWidget);
      expect(find.text('Icon'), findsNothing);
      expect(find.text('Tần suất'), findsNothing);
    });

    testWidgets('lưu hoạt động tính giờ: kind = timed, không có icon/goalFrequency', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(ActivityKind.timed));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Đọc sách');
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu hoạt động'));
      await tester.pumpAndSettle();

      final saved = storage.getActivities().single;
      expect(saved.kind, ActivityKind.timed);
      expect(saved.icon, isNull);
      expect(saved.goalFrequency, isNull);
    });
  });
}
