import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/features/dashboard/presentation/widgets/achievement_highlight_card.dart';
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

  const timedActivity = ActivityDefinition(
    id: 'a1',
    name: 'Đọc sách',
    domain: ActivityDomain.learning,
    timerType: ActivityTimerType.stopwatch,
    supervisionMode: ActivitySupervisionMode.relaxed,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = ActivityStorageService(prefs);
  });

  Widget buildApp() {
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: AchievementHighlightCard()),
      ),
    );
  }

  testWidgets('chưa có phiên nào: hiện thông báo mời bắt đầu', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Chưa có thành tựu nào'), findsOneWidget);
  });

  testWidgets('có phiên hôm nay của hoạt động tính giờ: hiện streak dài nhất và số ngày có hoạt động', (
    tester,
  ) async {
    await storage.saveActivities(const [timedActivity]);
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

    expect(
      find.textContaining('Streak dài nhất 1 ngày • 1 ngày có hoạt động'),
      findsOneWidget,
    );
  });

  testWidgets('check-in của hoạt động checkbox không tính vào card này', (tester) async {
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

    expect(find.textContaining('Chưa có thành tựu nào'), findsOneWidget);
  });

  testWidgets('bấm vào card: chuyển sang tab Thành tựu', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Chưa có thành tựu nào'));
    await tester.pumpAndSettle();

    expect(container.read(navIndexProvider), 3);
  });

  testWidgets('trên khổ điện thoại thật (360dp): không tràn ngang (overflow)', (
    tester,
  ) async {
    // Viewport mặc định của flutter_test rộng hơn điện thoại thật, không
    // bắt được lỗi tràn ngang — thu hẹp về khổ điện thoại phổ biến.
    tester.view.physicalSize = const Size(1080, 2316);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await storage.saveActivities(const [timedActivity]);
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

    expect(tester.takeException(), isNull);
  });
}
