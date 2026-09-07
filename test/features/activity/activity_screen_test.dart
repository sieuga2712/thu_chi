import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/features/activity/presentation/screens/activity_screen.dart';
import 'package:thu_chi/models/activity_definition.dart';
import 'package:thu_chi/models/activity_domain.dart';
import 'package:thu_chi/models/activity_goal_frequency.dart';
import 'package:thu_chi/models/activity_kind.dart';
import 'package:thu_chi/models/activity_session.dart';
import 'package:thu_chi/models/activity_supervision_mode.dart';
import 'package:thu_chi/models/activity_timer_type.dart';
import 'package:thu_chi/providers/category_settings_providers.dart';
import 'package:thu_chi/services/activity_storage_service.dart';

void main() {
  late SharedPreferences prefs;
  late ActivityStorageService storage;

  ActivityDefinition checkboxActivity({
    required String id,
    required String name,
    String icon = 'book',
    ActivityGoalFrequency goalFrequency = ActivityGoalFrequency.daily,
    int? weeklyGoalCount,
  }) {
    return ActivityDefinition(
      id: id,
      name: name,
      domain: ActivityDomain.personal,
      timerType: ActivityTimerType.stopwatch,
      supervisionMode: ActivitySupervisionMode.relaxed,
      kind: ActivityKind.checkbox,
      icon: icon,
      goalFrequency: goalFrequency,
      weeklyGoalCount: weeklyGoalCount,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = ActivityStorageService(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: ActivityScreen()),
    );
  }

  testWidgets('chưa có hoạt động nào hiện thông báo rỗng', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Chưa có hoạt động nào'), findsOneWidget);
  });

  testWidgets('thêm hoạt động checkbox mới rồi thấy xuất hiện trong danh sách, chưa tick', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Chuẩn bị đồ đạc');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu hoạt động'));
    await tester.pumpAndSettle();

    expect(find.text('Chuẩn bị đồ đạc'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('bấm vào dòng hoạt động: tick rồi bỏ tick lại được, phản ánh ngay', (tester) async {
    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

    await tester.tap(find.text('Đọc sách'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(storage.getSessions(), hasLength(1));

    await tester.tap(find.text('Đọc sách'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    expect(storage.getSessions(), isEmpty);
  });

  testWidgets('hoạt động Theo tuần hiện đúng tiến độ X/Y buổi tuần này', (tester) async {
    await storage.saveActivities([
      checkboxActivity(
        id: 'a1',
        name: 'Tập gym',
        goalFrequency: ActivityGoalFrequency.weekly,
        weeklyGoalCount: 4,
      ),
    ]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(activityId: 'a1', startedAt: now, endedAt: now),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('1/4 buổi tuần này'), findsOneWidget);
  });

  testWidgets('chuyển sang xem Tuần: lưới hiện đúng icon ở ngày đã tick', (tester) async {
    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(activityId: 'a1', startedAt: now, endedAt: now),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Tuần là chế độ mặc định.
    expect(find.text('Về tuần này'), findsNothing);
    expect(find.byTooltip('Đọc sách'), findsOneWidget);
  });

  testWidgets('bấm nút chuyển tuần trước/sau: cập nhật đúng dữ liệu và cho về lại tuần hiện tại', (
    tester,
  ) async {
    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(activityId: 'a1', startedAt: now, endedAt: now),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Đọc sách'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    // Tuần trước không có check-in nào -> không còn icon, có nút về lại
    // tuần hiện tại.
    expect(find.byTooltip('Đọc sách'), findsNothing);
    expect(find.text('Về tuần này'), findsOneWidget);

    await tester.tap(find.text('Về tuần này'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Đọc sách'), findsOneWidget);
    expect(find.text('Về tuần này'), findsNothing);
  });

  testWidgets('chuyển sang xem Tháng hiện lưới nhiệt', (tester) async {
    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(activityId: 'a1', startedAt: now, endedAt: now),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tháng'));
    await tester.pumpAndSettle();

    expect(find.text('Ít'), findsOneWidget);
    expect(find.text('Nhiều'), findsOneWidget);
  });

  group('chọn ngày quá khứ', () {
    /// Chọn "hôm qua" trong DatePicker hệ thống mở từ icon lịch trên
    /// AppBar. Nếu hôm nay là ngày 1 đầu tháng thì "hôm qua" ở tháng
    /// trước — lùi 1 tháng trong lịch trước khi bấm ngày đó.
    Future<void> pickYesterday(WidgetTester tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      if (yesterday.month != DateTime.now().month) {
        await tester.tap(find.byTooltip('Previous month'));
        await tester.pumpAndSettle();
      }

      await tester.tap(
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.text('${yesterday.day}'),
        ),
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    testWidgets('chọn hôm qua rồi tick: hiện banner + dialog xác nhận, đồng ý thì tick', (
      tester,
    ) async {
      await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await pickYesterday(tester);

      expect(find.textContaining('Đang tích cho ngày'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      await tester.tap(find.text('Đọc sách'));
      await tester.pumpAndSettle();

      expect(find.text('Thay đổi ngày trong quá khứ?'), findsOneWidget);

      await tester.tap(find.text('Đồng ý'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(
        storage.getSessions().single.startedAt,
        DateTime(yesterday.year, yesterday.month, yesterday.day),
      );
    });

    testWidgets('chọn hôm qua rồi tick nhưng bấm Hủy: không đổi gì', (tester) async {
      await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await pickYesterday(tester);

      await tester.tap(find.text('Đọc sách'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      expect(storage.getSessions(), isEmpty);
    });

    testWidgets('bấm "Về hôm nay": tick lại không cần xác nhận', (tester) async {
      await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await pickYesterday(tester);

      await tester.tap(find.text('Về hôm nay'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Đang tích cho ngày'), findsNothing);

      await tester.tap(find.text('Đọc sách'));
      await tester.pumpAndSettle();

      // Không có dialog xác nhận nào cho hôm nay — tick ngay.
      expect(find.text('Thay đổi ngày trong quá khứ?'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
