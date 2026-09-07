/// Số thứ tự tuần theo chuẩn ISO 8601 (tuần bắt đầu Thứ 2, tuần 1 là tuần
/// chứa Thứ Năm đầu tiên của năm). Một năm có 52 hoặc 53 tuần ISO — không
/// bao giờ có 54, nhưng UI không giới hạn cứng số tuần hiển thị, cho phép
/// lướt qua/lại tự do kể cả sang năm khác.
int isoWeekNumber(DateTime date) {
  final thursday = _thursdayOfWeek(date);
  final firstDayOfYear = DateTime(thursday.year, 1, 1);
  return ((thursday.difference(firstDayOfYear).inDays) ~/ 7) + 1;
}

/// Năm ISO của tuần chứa [date] — có thể khác [date].year ở vài ngày cuối
/// tháng 12/đầu tháng 1 (ví dụ 29-31/12 có thể thuộc tuần 1 của năm sau).
int isoWeekYear(DateTime date) => _thursdayOfWeek(date).year;

DateTime _thursdayOfWeek(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return d.add(Duration(days: 4 - d.weekday));
}
