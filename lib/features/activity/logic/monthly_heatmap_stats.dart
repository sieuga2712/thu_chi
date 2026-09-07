import '../../../models/activity_session.dart';

/// Số check-in (không phải thời gian) của từng ngày trong tháng chứa [now]
/// — quy đổi mỗi check-in thành 1 phút danh nghĩa để tái dùng nguyên
/// [MonthlyActivityHeatmap] (vốn nhận [Duration]) cho hoạt động checkbox,
/// vốn dĩ [ActivitySession.totalDuration] luôn là 0 (startedAt == endedAt).
Map<DateTime, Duration> monthlyCheckInCountsByDay(
  List<ActivitySession> sessions, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final firstDay = DateTime(reference.year, reference.month, 1);
  final daysInMonth = DateTime(reference.year, reference.month + 1, 0).day;

  final result = <DateTime, Duration>{
    for (var i = 0; i < daysInMonth; i++)
      firstDay.add(Duration(days: i)): Duration.zero,
  };

  final monthStart = firstDay;
  final monthEnd = DateTime(reference.year, reference.month + 1, 1);

  for (final s in sessions) {
    if (s.startedAt.isBefore(monthStart) || !s.startedAt.isBefore(monthEnd)) {
      continue;
    }
    final day = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
    result[day] = (result[day] ?? Duration.zero) + const Duration(minutes: 1);
  }

  return result;
}

/// Tổng thời gian (mọi hoạt động cộng lại) của từng ngày trong tháng chứa
/// [now] — luôn trả đủ mọi ngày trong tháng (kể cả ngày không có hoạt động
/// nào, giá trị [Duration.zero]) để vẽ lưới nhiệt kiểu GitHub contribution.
Map<DateTime, Duration> monthlyTotalsByDay(
  List<ActivitySession> sessions, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final firstDay = DateTime(reference.year, reference.month, 1);
  final daysInMonth = DateTime(reference.year, reference.month + 1, 0).day;

  final result = <DateTime, Duration>{
    for (var i = 0; i < daysInMonth; i++)
      firstDay.add(Duration(days: i)): Duration.zero,
  };

  final monthStart = firstDay;
  final monthEnd = DateTime(reference.year, reference.month + 1, 1);

  for (final s in sessions) {
    if (s.startedAt.isBefore(monthStart) || !s.startedAt.isBefore(monthEnd))
      continue;
    final day = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
    result[day] = (result[day] ?? Duration.zero) + s.totalDuration;
  }

  return result;
}
