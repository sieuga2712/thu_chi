import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/features/activity/providers/activity_sessions_provider.dart';
import 'package:thu_chi/models/activity_session.dart';
import 'package:thu_chi/providers/category_settings_providers.dart';
import 'package:thu_chi/services/activity_storage_service.dart';

void main() {
  late SharedPreferences prefs;
  late ActivityStorageService storage;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = ActivityStorageService(prefs);
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
  });

  test('build() đọc đúng session đã lưu sẵn trong storage', () async {
    await storage.addSession(
      ActivitySession(
        activityId: 'a1',
        startedAt: DateTime(2026, 9, 7),
        endedAt: DateTime(2026, 9, 7),
      ),
    );

    final sessions = container.read(activitySessionsProvider);

    expect(sessions, hasLength(1));
  });

  test('recordSession ghi qua storage và cập nhật state ngay', () async {
    final session = ActivitySession(
      activityId: 'a1',
      startedAt: DateTime(2026, 9, 7, 8, 0),
      endedAt: DateTime(2026, 9, 7, 8, 30),
    );

    await container.read(activitySessionsProvider.notifier).recordSession(session);

    expect(container.read(activitySessionsProvider), [session]);
    expect(storage.getSessions(), [session]);
  });

  test('checkIn tạo 1 session đánh dấu (duration = 0) cho đúng ngày', () async {
    final day = DateTime(2026, 9, 7);

    await container
        .read(activitySessionsProvider.notifier)
        .checkIn('habit1', day: day);

    final sessions = container.read(activitySessionsProvider);
    expect(sessions, hasLength(1));
    expect(sessions.single.activityId, 'habit1');
    expect(sessions.single.startedAt, day);
    expect(sessions.single.totalDuration, Duration.zero);
  });

  test('checkOut xóa đúng session đã checkIn cùng ngày', () async {
    final day = DateTime(2026, 9, 7);
    final notifier = container.read(activitySessionsProvider.notifier);
    await notifier.checkIn('habit1', day: day);

    await notifier.checkOut('habit1', day: day);

    expect(container.read(activitySessionsProvider), isEmpty);
    expect(storage.getSessions(), isEmpty);
  });

  test('checkOut ngày không có check-in thì không đổi gì', () async {
    final notifier = container.read(activitySessionsProvider.notifier);
    await notifier.checkIn('habit1', day: DateTime(2026, 9, 7));

    await notifier.checkOut('habit1', day: DateTime(2026, 9, 8));

    expect(container.read(activitySessionsProvider), hasLength(1));
  });
}
