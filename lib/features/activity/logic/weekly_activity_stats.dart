/// 7 ngày (Thứ 2 → Chủ nhật) của tuần chứa [now].
List<DateTime> currentWeekDays({DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return List.generate(7, (i) => monday.add(Duration(days: i)));
}
