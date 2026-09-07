import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/models/activity_definition.dart';
import 'package:thu_chi/models/activity_domain.dart';
import 'package:thu_chi/models/activity_session.dart';
import 'package:thu_chi/models/activity_supervision_mode.dart';
import 'package:thu_chi/models/activity_timer_type.dart';
import 'package:thu_chi/models/active_session.dart';
import 'package:thu_chi/models/distraction_interval.dart';
import 'package:thu_chi/services/activity_storage_service.dart';

void main() {
  late ActivityStorageService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = ActivityStorageService(prefs);
  });

  const activity = ActivityDefinition(
    id: 'a1',
    name: 'Đọc sách',
    domain: ActivityDomain.learning,
    timerType: ActivityTimerType.stopwatch,
    supervisionMode: ActivitySupervisionMode.strict,
  );

  group('activities', () {
    test('chưa lưu gì thì getActivities trả về danh sách rỗng', () {
      expect(service.getActivities(), isEmpty);
    });

    test('saveActivities rồi getActivities đọc lại đúng, giữ nguyên mọi trường', () async {
      await service.saveActivities([activity]);

      final result = service.getActivities();

      expect(result, hasLength(1));
      expect(result.single, activity);
    });
  });

  group('sessions', () {
    test('chưa có phiên nào thì getSessions trả về danh sách rỗng', () {
      expect(service.getSessions(), isEmpty);
    });

    test('addSession nối thêm vào danh sách, không ghi đè phiên cũ', () async {
      final s1 = ActivitySession(
        activityId: 'a1',
        startedAt: DateTime(2026, 9, 7, 8, 0),
        endedAt: DateTime(2026, 9, 7, 8, 30),
      );
      final s2 = ActivitySession(
        activityId: 'a1',
        startedAt: DateTime(2026, 9, 7, 9, 0),
        endedAt: DateTime(2026, 9, 7, 9, 20),
        distractions: [
          DistractionInterval(
            start: DateTime(2026, 9, 7, 9, 5),
            end: DateTime(2026, 9, 7, 9, 7),
          ),
        ],
      );

      await service.addSession(s1);
      await service.addSession(s2);

      final result = service.getSessions();
      expect(result, hasLength(2));
      expect(result[1].distractions.single.duration, const Duration(minutes: 2));
    });

    test('removeSession xóa đúng session, giữ nguyên các session khác', () async {
      final s1 = ActivitySession(
        activityId: 'a1',
        startedAt: DateTime(2026, 9, 7, 8, 0),
        endedAt: DateTime(2026, 9, 7, 8, 30),
      );
      final s2 = ActivitySession(
        activityId: 'a1',
        startedAt: DateTime(2026, 9, 7, 9, 0),
        endedAt: DateTime(2026, 9, 7, 9, 20),
      );
      await service.addSession(s1);
      await service.addSession(s2);

      await service.removeSession(s1);

      final result = service.getSessions();
      expect(result, hasLength(1));
      expect(result.single, s2);
    });

    test('removeSession với session không tồn tại thì không đổi gì', () async {
      final s1 = ActivitySession(
        activityId: 'a1',
        startedAt: DateTime(2026, 9, 7, 8, 0),
        endedAt: DateTime(2026, 9, 7, 8, 30),
      );
      await service.addSession(s1);

      await service.removeSession(
        ActivitySession(
          activityId: 'khong-ton-tai',
          startedAt: DateTime(2026, 9, 7),
          endedAt: DateTime(2026, 9, 7),
        ),
      );

      expect(service.getSessions(), hasLength(1));
    });
  });

  group('active session', () {
    test('chưa có phiên đang chạy thì getActiveSession trả về null', () {
      expect(service.getActiveSession(), isNull);
    });

    test('setActiveSession rồi getActiveSession đọc lại đúng', () async {
      final active = ActiveSession(activityId: 'a1', startedAt: DateTime(2026, 9, 7, 8, 0));

      await service.setActiveSession(active);

      expect(service.getActiveSession(), active);
    });

    test('setActiveSession(null) xóa phiên đang chạy', () async {
      await service.setActiveSession(
        ActiveSession(activityId: 'a1', startedAt: DateTime(2026, 9, 7, 8, 0)),
      );
      await service.setActiveSession(null);

      expect(service.getActiveSession(), isNull);
    });
  });
}
