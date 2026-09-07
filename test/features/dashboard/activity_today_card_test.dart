import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/features/dashboard/presentation/widgets/activity_today_card.dart';
import 'package:thu_chi/models/activity_definition.dart';
import 'package:thu_chi/models/activity_domain.dart';
import 'package:thu_chi/models/activity_goal_frequency.dart';
import 'package:thu_chi/models/activity_kind.dart';
import 'package:thu_chi/models/activity_session.dart';
import 'package:thu_chi/models/activity_supervision_mode.dart';
import 'package:thu_chi/models/activity_timer_type.dart';
import 'package:thu_chi/providers/category_settings_providers.dart';
import 'package:thu_chi/providers/nav_provider.dart';
import 'package:thu_chi/services/activity_storage_service.dart';

void main() {
  late SharedPreferences prefs;
  late ActivityStorageService storage;
  late ProviderContainer container;

  ActivityDefinition checkboxActivity({
    required String id,
    required String name,
    ActivityGoalFrequency goalFrequency = ActivityGoalFrequency.daily,
  }) {
    return ActivityDefinition(
      id: id,
      name: name,
      domain: ActivityDomain.personal,
      timerType: ActivityTimerType.stopwatch,
      supervisionMode: ActivitySupervisionMode.relaxed,
      kind: ActivityKind.checkbox,
      icon: 'task',
      goalFrequency: goalFrequency,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = ActivityStorageService(prefs);
  });

  Widget buildApp() {
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: ActivityTodayCard()),
      ),
    );
  }

  /// Viewport mặc định của flutter_test (800x600 logical) rộng hơn nhiều so
  /// với điện thoại thật, nên không bắt được lỗi overflow ngang trên máy
  /// thật — thu hẹp về khổ điện thoại phổ biến (360 logical px) để test có
  /// ý nghĩa với các Row/Wrap nhạy cảm với bề rộng.
  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2316);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('chưa có hoạt động nào: hiện thông báo mời thêm hoạt động', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Chưa có hoạt động nào'),
      findsOneWidget,
    );
  });

  testWidgets('có hoạt động, chưa tick: streak 0, 0/1, nút tick nhanh', (tester) async {
    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('0 ngày streak'), findsOneWidget);
    expect(find.textContaining('0/1 hoạt động hôm nay'), findsOneWidget);
    expect(find.textContaining('Tick nhanh: Đọc sách'), findsOneWidget);
  });

  testWidgets('đã tick hôm nay: đếm đúng số hoạt động và streak', (tester) async {
    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(activityId: 'a1', startedAt: now, endedAt: now),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('1 ngày streak'), findsOneWidget);
    expect(find.textContaining('1/1 hoạt động hôm nay'), findsOneWidget);
    expect(find.textContaining('Đã tick hết hoạt động hằng ngày'), findsOneWidget);
  });

  testWidgets('trên khổ điện thoại thật (360dp): không tràn ngang (overflow)', (
    tester,
  ) async {
    setPhoneViewport(tester);

    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);
    final now = DateTime.now();
    await storage.addSession(
      ActivitySession(activityId: 'a1', startedAt: now, endedAt: now),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('bấm nút tick nhanh: tick luôn hoạt động, cập nhật ngay tại chỗ', (tester) async {
    await storage.saveActivities([checkboxActivity(id: 'a1', name: 'Đọc sách')]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Tick nhanh: Đọc sách'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1/1 hoạt động hôm nay'), findsOneWidget);
    expect(storage.getSessions(), hasLength(1));
    // Bấm nút tick nhanh chỉ tick tại chỗ, không điều hướng đi đâu.
    expect(container.read(navIndexProvider), 0);
  });

  testWidgets('bấm vào card (ngoài nút): chuyển sang tab Hoạt động', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Chưa có hoạt động nào'));
    await tester.pumpAndSettle();

    expect(container.read(navIndexProvider), 2);
  });
}
