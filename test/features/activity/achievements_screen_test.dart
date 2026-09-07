import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/features/activity/presentation/screens/achievements_screen.dart';
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = ActivityStorageService(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: AchievementsScreen()),
    );
  }

  testWidgets('chưa có phiên nào: streak 0, chưa có hoạt động tháng này', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('0 ngày'), findsWidgets);
    expect(find.textContaining('Chưa có hoạt động nào trong tháng này'), findsOneWidget);
  });

  testWidgets('có phiên hôm nay: hiện đúng streak và tổng thời gian tháng này', (tester) async {
    await storage.saveActivities(const [
      ActivityDefinition(
        id: 'a1',
        name: 'Đọc sách',
        domain: ActivityDomain.learning,
        timerType: ActivityTimerType.stopwatch,
        supervisionMode: ActivitySupervisionMode.relaxed,
      ),
    ]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(
        activityId: 'a1',
        startedAt: now.subtract(const Duration(hours: 1)),
        endedAt: now,
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('1 ngày'), findsWidgets);
    // Xuất hiện 2 lần: card điều khiển ở "Đang theo dõi" + dòng tổng thời
    // gian ở "Tháng này".
    expect(find.text('Đọc sách'), findsNWidgets(2));
    expect(find.textContaining('giờ'), findsWidgets);
  });

  testWidgets('hoạt động tính giờ hiện ở "Đang theo dõi" với nút Bắt đầu', (tester) async {
    await storage.saveActivities(const [
      ActivityDefinition(
        id: 'a1',
        name: 'Đọc sách',
        domain: ActivityDomain.learning,
        timerType: ActivityTimerType.stopwatch,
        supervisionMode: ActivitySupervisionMode.relaxed,
      ),
    ]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Đang theo dõi'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });

  testWidgets('check-in của hoạt động checkbox không tính vào streak/thống kê ở đây', (
    tester,
  ) async {
    await storage.saveActivities(const [
      ActivityDefinition(
        id: 'habit1',
        name: 'Chuẩn bị đồ đạc',
        domain: ActivityDomain.personal,
        timerType: ActivityTimerType.stopwatch,
        supervisionMode: ActivitySupervisionMode.relaxed,
        kind: ActivityKind.checkbox,
        icon: 'luggage',
        goalFrequency: ActivityGoalFrequency.daily,
      ),
    ]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(activityId: 'habit1', startedAt: now, endedAt: now),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('0 ngày'), findsWidgets);
    expect(find.textContaining('Chưa có hoạt động nào trong tháng này'), findsOneWidget);
    expect(find.text('Chuẩn bị đồ đạc'), findsNothing);
  });

  group('xóa hoạt động', () {
    const activity = ActivityDefinition(
      id: 'a1',
      name: 'Đọc sách',
      domain: ActivityDomain.learning,
      timerType: ActivityTimerType.stopwatch,
      supervisionMode: ActivitySupervisionMode.relaxed,
    );

    testWidgets('bấm nút xóa rồi xác nhận: xóa khỏi danh sách và khỏi storage', (tester) async {
      await storage.saveActivities(const [activity]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Xóa hoạt động?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
      await tester.pumpAndSettle();

      expect(find.text('Đọc sách'), findsNothing);
      expect(storage.getActivities(), isEmpty);
      expect(find.textContaining('Chưa có hoạt động tính giờ nào'), findsOneWidget);
    });

    testWidgets('bấm nút xóa rồi Hủy: không đổi gì', (tester) async {
      await storage.saveActivities(const [activity]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Đọc sách'), findsOneWidget);
      expect(storage.getActivities(), hasLength(1));
    });

    testWidgets('không hiện nút xóa khi hoạt động đang chạy', (tester) async {
      await storage.saveActivities(const [activity]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bắt đầu'));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsNothing);

      // Dừng đồng hồ để không còn Timer.periodic treo lại sau khi test kết
      // thúc (flutter_test coi đó là lỗi).
      await tester.tap(find.text('Dừng'));
      await tester.pumpAndSettle();
    });
  });
}
