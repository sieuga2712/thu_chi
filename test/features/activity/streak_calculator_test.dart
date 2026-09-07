import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/activity/logic/streak_calculator.dart';
import 'package:thu_chi/models/activity_session.dart';

void main() {
  final now = DateTime(2026, 9, 7, 20, 0); // Thứ Hai

  ActivitySession sessionOn(DateTime day) {
    return ActivitySession(
      activityId: 'a',
      startedAt: DateTime(day.year, day.month, day.day, 8, 0),
      endedAt: DateTime(day.year, day.month, day.day, 8, 30),
    );
  }

  test('không có phiên nào thì streak = 0', () {
    final result = computeStreak(const [], now: now);
    expect(result.current, 0);
    expect(result.longest, 0);
  });

  test('có hoạt động liên tục 3 ngày tính đến hôm nay thì streak hiện tại = 3', () {
    final sessions = [
      sessionOn(DateTime(2026, 9, 5)),
      sessionOn(DateTime(2026, 9, 6)),
      sessionOn(DateTime(2026, 9, 7)), // hôm nay
    ];

    final result = computeStreak(sessions, now: now);

    expect(result.current, 3);
  });

  test('hôm nay chưa có hoạt động nhưng hôm qua có thì streak vẫn tính (chưa đứt)', () {
    final sessions = [sessionOn(DateTime(2026, 9, 5)), sessionOn(DateTime(2026, 9, 6))];

    final result = computeStreak(sessions, now: now);

    expect(result.current, 2);
  });

  test('đứt quãng 1 ngày thì streak hiện tại chỉ tính từ sau chỗ đứt', () {
    final sessions = [
      sessionOn(DateTime(2026, 9, 1)),
      // đứt ngày 2-3
      sessionOn(DateTime(2026, 9, 4)),
      sessionOn(DateTime(2026, 9, 5)),
      sessionOn(DateTime(2026, 9, 6)),
      sessionOn(DateTime(2026, 9, 7)),
    ];

    final result = computeStreak(sessions, now: now);

    expect(result.current, 4);
  });

  test('cả hôm nay và hôm qua đều không có hoạt động thì streak hiện tại = 0', () {
    final sessions = [sessionOn(DateTime(2026, 9, 1))];

    final result = computeStreak(sessions, now: now);

    expect(result.current, 0);
  });

  test('streak dài nhất lấy đúng dải liên tiếp dài nhất trong lịch sử, kể cả đã đứt từ lâu', () {
    final sessions = [
      sessionOn(DateTime(2026, 8, 1)),
      sessionOn(DateTime(2026, 8, 2)),
      sessionOn(DateTime(2026, 8, 3)),
      sessionOn(DateTime(2026, 8, 4)),
      sessionOn(DateTime(2026, 8, 5)), // dải dài 5 ngày, đã đứt hẳn từ lâu
      sessionOn(DateTime(2026, 9, 7)), // hôm nay, streak hiện tại chỉ 1
    ];

    final result = computeStreak(sessions, now: now);

    expect(result.current, 1);
    expect(result.longest, 5);
  });

  test('nhiều phiên trong cùng 1 ngày chỉ tính là 1 ngày, không nhân đôi streak', () {
    final sessions = [
      sessionOn(DateTime(2026, 9, 7)),
      ActivitySession(
        activityId: 'b',
        startedAt: DateTime(2026, 9, 7, 14, 0),
        endedAt: DateTime(2026, 9, 7, 14, 30),
      ),
    ];

    final result = computeStreak(sessions, now: now);

    expect(result.current, 1);
  });
}
