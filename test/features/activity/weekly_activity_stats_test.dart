import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/activity/logic/weekly_activity_stats.dart';

void main() {
  // Thứ Năm 2026-09-10 -> tuần chứa là Thứ 2 2026-09-07 -> CN 2026-09-13.
  final now = DateTime(2026, 9, 10, 10, 0);

  test('currentWeekDays trả đúng 7 ngày Thứ 2 đến Chủ nhật', () {
    final days = currentWeekDays(now: now);

    expect(days, hasLength(7));
    expect(days.first, DateTime(2026, 9, 7));
    expect(days.last, DateTime(2026, 9, 13));
  });
}
