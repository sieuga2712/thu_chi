import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/activity/logic/monthly_activity_stats.dart';
import 'package:thu_chi/models/activity_session.dart';

void main() {
  final now = DateTime(2026, 9, 15);

  ActivitySession session(String activityId, DateTime start, Duration duration) {
    return ActivitySession(activityId: activityId, startedAt: start, endedAt: start.add(duration));
  }

  group('totalDurationThisMonth', () {
    test('chỉ cộng phiên bắt đầu trong tháng hiện tại', () {
      final sessions = [
        session('a', DateTime(2026, 8, 31, 23, 0), const Duration(minutes: 10)), // tháng trước
        session('a', DateTime(2026, 9, 1, 0, 0), const Duration(minutes: 20)),
        session('a', DateTime(2026, 9, 30, 23, 59), const Duration(minutes: 15)),
        session('a', DateTime(2026, 10, 1, 0, 0), const Duration(minutes: 5)), // tháng sau
      ];

      final result = totalDurationThisMonth(sessions, now: now);

      expect(result['a'], const Duration(minutes: 35));
    });

    test('tách riêng theo từng activityId', () {
      final sessions = [
        session('a', DateTime(2026, 9, 5), const Duration(minutes: 20)),
        session('b', DateTime(2026, 9, 6), const Duration(minutes: 30)),
      ];

      final result = totalDurationThisMonth(sessions, now: now);

      expect(result['a'], const Duration(minutes: 20));
      expect(result['b'], const Duration(minutes: 30));
    });
  });

  group('totalActiveDays', () {
    test('đếm đúng số ngày khác nhau, không nhân đôi khi nhiều phiên cùng ngày', () {
      final sessions = [
        session('a', DateTime(2026, 9, 1, 8, 0), const Duration(minutes: 10)),
        session('a', DateTime(2026, 9, 1, 14, 0), const Duration(minutes: 10)),
        session('b', DateTime(2026, 9, 2, 8, 0), const Duration(minutes: 10)),
      ];

      expect(totalActiveDays(sessions), 2);
    });

    test('danh sách rỗng trả về 0', () {
      expect(totalActiveDays(const []), 0);
    });
  });

  group('lifetimeTotalDuration', () {
    test('cộng dồn toàn bộ lịch sử, không giới hạn theo tháng', () {
      final sessions = [
        session('a', DateTime(2026, 1, 1), const Duration(hours: 1)),
        session('a', DateTime(2026, 9, 1), const Duration(hours: 2)),
      ];

      final result = lifetimeTotalDuration(sessions);

      expect(result['a'], const Duration(hours: 3));
    });
  });
}
