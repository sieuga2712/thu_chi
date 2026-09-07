import '../../../models/activity_session.dart';

/// Tổng thời gian mỗi hoạt động trong tháng chứa [now] — key là activityId.
Map<String, Duration> totalDurationThisMonth(
  List<ActivitySession> sessions, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final start = DateTime(reference.year, reference.month, 1);
  final end = DateTime(reference.year, reference.month + 1, 1);

  final result = <String, Duration>{};
  for (final s in sessions) {
    if (s.startedAt.isBefore(start) || !s.startedAt.isBefore(end)) continue;
    result[s.activityId] =
        (result[s.activityId] ?? Duration.zero) + s.totalDuration;
  }
  return result;
}

/// Số ngày khác nhau trong toàn bộ lịch sử có ít nhất 1 phiên hoạt động —
/// dùng cho thống kê "tổng số ngày có hoạt động".
int totalActiveDays(List<ActivitySession> sessions) {
  final days = sessions.map((s) {
    final d = s.startedAt;
    return DateTime(d.year, d.month, d.day);
  }).toSet();
  return days.length;
}

/// Tổng thời gian toàn bộ lịch sử của mỗi hoạt động — key là activityId.
Map<String, Duration> lifetimeTotalDuration(List<ActivitySession> sessions) {
  final result = <String, Duration>{};
  for (final s in sessions) {
    result[s.activityId] =
        (result[s.activityId] ?? Duration.zero) + s.totalDuration;
  }
  return result;
}
