import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/activity/logic/iso_week.dart';

void main() {
  test('01/01/2026 (Thứ Năm) là tuần 1 của năm 2026', () {
    expect(isoWeekNumber(DateTime(2026, 1, 1)), 1);
    expect(isoWeekYear(DateTime(2026, 1, 1)), 2026);
  });

  test('29-31/12/2025 thuộc tuần 1 của năm 2026 (không phải năm 2025)', () {
    expect(isoWeekNumber(DateTime(2025, 12, 29)), 1);
    expect(isoWeekYear(DateTime(2025, 12, 29)), 2026);
    expect(isoWeekNumber(DateTime(2025, 12, 31)), 1);
    expect(isoWeekYear(DateTime(2025, 12, 31)), 2026);
  });

  test('05/01/2026 (Thứ Hai) là tuần 2 của năm 2026', () {
    expect(isoWeekNumber(DateTime(2026, 1, 5)), 2);
    expect(isoWeekYear(DateTime(2026, 1, 5)), 2026);
  });

  test('28/12/2026 là tuần 53 — năm 2026 có 53 tuần ISO', () {
    expect(isoWeekNumber(DateTime(2026, 12, 28)), 53);
    expect(isoWeekYear(DateTime(2026, 12, 28)), 2026);
  });

  test('07-13/09/2026 (tuần hiện tại dùng làm mốc test khác) là tuần 37', () {
    expect(isoWeekNumber(DateTime(2026, 9, 7)), 37);
    expect(isoWeekNumber(DateTime(2026, 9, 13)), 37);
  });

  test('mọi ngày trong cùng 1 tuần ISO cho cùng 1 số tuần', () {
    final monday = DateTime(2026, 9, 7);
    for (var i = 0; i < 7; i++) {
      expect(isoWeekNumber(monday.add(Duration(days: i))), 37);
    }
  });
}
