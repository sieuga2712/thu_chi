import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/activity/logic/habit_week_stats.dart';
import 'package:thu_chi/models/activity_session.dart';

void main() {
  // Thứ Năm 2026-09-10 -> tuần chứa là Thứ 2 2026-09-07 -> CN 2026-09-13.
  final now = DateTime(2026, 9, 10, 10, 0);

  ActivitySession checkIn(String activityId, DateTime day) {
    return ActivitySession(activityId: activityId, startedAt: day, endedAt: day);
  }

  group('checkboxCompletionsByDay', () {
    test('trả đủ 7 ngày, ngày chưa tick gì thì danh sách rỗng', () {
      final result = checkboxCompletionsByDay(const [], now: now);

      expect(result.keys, hasLength(7));
      expect(result[DateTime(2026, 9, 7)], isEmpty);
    });

    test('gom đúng activityId đã tick vào từng ngày, không trùng lặp', () {
      final sessions = [
        checkIn('a', DateTime(2026, 9, 8)),
        checkIn('b', DateTime(2026, 9, 8)),
        checkIn('a', DateTime(2026, 9, 8)), // trùng, không nhân đôi
        checkIn('a', DateTime(2026, 9, 9)),
      ];

      final result = checkboxCompletionsByDay(sessions, now: now);

      expect(result[DateTime(2026, 9, 8)], ['a', 'b']);
      expect(result[DateTime(2026, 9, 9)], ['a']);
      expect(result[DateTime(2026, 9, 7)], isEmpty);
    });

    test('bỏ qua session ngoài tuần hiện tại', () {
      final sessions = [
        checkIn('a', DateTime(2026, 9, 6)), // tuần trước
        checkIn('a', DateTime(2026, 9, 14)), // tuần sau
      ];

      final result = checkboxCompletionsByDay(sessions, now: now);

      for (final ids in result.values) {
        expect(ids, isEmpty);
      }
    });
  });

  group('weeklyCheckInDays', () {
    test('đếm đúng số ngày khác nhau có check-in trong tuần cho 1 activity', () {
      final sessions = [
        checkIn('gym', DateTime(2026, 9, 8)),
        checkIn('gym', DateTime(2026, 9, 10)),
        checkIn('gym', DateTime(2026, 9, 12)),
        checkIn('other', DateTime(2026, 9, 9)),
      ];

      expect(weeklyCheckInDays(sessions, 'gym', now: now), 3);
      expect(weeklyCheckInDays(sessions, 'other', now: now), 1);
      expect(weeklyCheckInDays(sessions, 'khong-ton-tai', now: now), 0);
    });

    test('không đếm session ngoài tuần hiện tại', () {
      final sessions = [checkIn('gym', DateTime(2026, 9, 6))];

      expect(weeklyCheckInDays(sessions, 'gym', now: now), 0);
    });
  });
}
