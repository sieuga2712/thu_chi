import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/activity/logic/monthly_heatmap_stats.dart';
import 'package:thu_chi/models/activity_session.dart';

void main() {
  final now = DateTime(2026, 9, 15);

  ActivitySession session(String activityId, DateTime start, Duration duration) {
    return ActivitySession(activityId: activityId, startedAt: start, endedAt: start.add(duration));
  }

  test('trả đủ mọi ngày trong tháng (30 ngày cho tháng 9), ngày rỗng = Duration.zero', () {
    final result = monthlyTotalsByDay(const [], now: now);

    expect(result.keys, hasLength(30));
    expect(result[DateTime(2026, 9, 1)], Duration.zero);
    expect(result[DateTime(2026, 9, 30)], Duration.zero);
  });

  test('cộng dồn đúng nhiều hoạt động trong cùng 1 ngày', () {
    final sessions = [
      session('a', DateTime(2026, 9, 10, 8, 0), const Duration(minutes: 20)),
      session('b', DateTime(2026, 9, 10, 14, 0), const Duration(minutes: 30)),
    ];

    final result = monthlyTotalsByDay(sessions, now: now);

    expect(result[DateTime(2026, 9, 10)], const Duration(minutes: 50));
  });

  test('bỏ qua phiên ngoài tháng hiện tại', () {
    final sessions = [
      session('a', DateTime(2026, 8, 31, 23, 59), const Duration(minutes: 10)),
      session('a', DateTime(2026, 10, 1, 0, 0), const Duration(minutes: 10)),
    ];

    final result = monthlyTotalsByDay(sessions, now: now);

    expect(result.values.every((d) => d == Duration.zero), isTrue);
  });

  test('tháng 2 năm không nhuận trả đúng 28 ngày', () {
    final result = monthlyTotalsByDay(const [], now: DateTime(2026, 2, 10));

    expect(result.keys, hasLength(28));
  });

  group('monthlyCheckInCountsByDay', () {
    test('mỗi check-in (duration = 0) quy đổi thành 1 phút danh nghĩa', () {
      final sessions = [
        session('a', DateTime(2026, 9, 10), Duration.zero),
        session('b', DateTime(2026, 9, 10), Duration.zero),
        session('a', DateTime(2026, 9, 11), Duration.zero),
      ];

      final result = monthlyCheckInCountsByDay(sessions, now: now);

      expect(result[DateTime(2026, 9, 10)], const Duration(minutes: 2));
      expect(result[DateTime(2026, 9, 11)], const Duration(minutes: 1));
      expect(result[DateTime(2026, 9, 1)], Duration.zero);
    });

    test('trả đủ mọi ngày trong tháng kể cả ngày không có check-in', () {
      final result = monthlyCheckInCountsByDay(const [], now: now);

      expect(result.keys, hasLength(30));
      expect(result.values.every((d) => d == Duration.zero), isTrue);
    });
  });
}
