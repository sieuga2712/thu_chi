import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/activity/logic/today_sessions_calculator.dart';
import 'package:thu_chi/models/activity_session.dart';

void main() {
  final now = DateTime(2026, 9, 7, 15, 0);

  ActivitySession session(String activityId, DateTime start, Duration duration) {
    return ActivitySession(activityId: activityId, startedAt: start, endedAt: start.add(duration));
  }

  group('sessionsToday', () {
    test('chỉ lấy phiên bắt đầu trong ngày hôm nay, sắp mới nhất trước', () {
      final sessions = [
        session('a', DateTime(2026, 9, 6, 23, 59), const Duration(minutes: 10)), // hôm qua
        session('a', DateTime(2026, 9, 7, 8, 0), const Duration(minutes: 20)),
        session('b', DateTime(2026, 9, 7, 10, 0), const Duration(minutes: 15)),
        session('a', DateTime(2026, 9, 8, 0, 0), const Duration(minutes: 5)), // ngày mai
      ];

      final result = sessionsToday(sessions, now: now);

      expect(result, hasLength(2));
      expect(result[0].startedAt, DateTime(2026, 9, 7, 10, 0));
      expect(result[1].startedAt, DateTime(2026, 9, 7, 8, 0));
    });

    test('không có phiên nào hôm nay trả về danh sách rỗng', () {
      final sessions = [session('a', DateTime(2026, 9, 6, 8, 0), const Duration(minutes: 10))];

      expect(sessionsToday(sessions, now: now), isEmpty);
    });
  });

  group('totalDurationByActivity', () {
    test('cộng dồn đúng theo từng activityId', () {
      final sessions = [
        session('a', DateTime(2026, 9, 7, 8, 0), const Duration(minutes: 20)),
        session('a', DateTime(2026, 9, 7, 10, 0), const Duration(minutes: 15)),
        session('b', DateTime(2026, 9, 7, 12, 0), const Duration(minutes: 30)),
      ];

      final result = totalDurationByActivity(sessions);

      expect(result['a'], const Duration(minutes: 35));
      expect(result['b'], const Duration(minutes: 30));
    });

    test('danh sách rỗng trả về map rỗng', () {
      expect(totalDurationByActivity(const []), isEmpty);
    });
  });
}
