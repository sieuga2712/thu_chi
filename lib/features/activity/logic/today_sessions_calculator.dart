import '../../../models/activity_session.dart';

/// Các phiên đã hoàn thành trong ngày hôm nay (theo [now]), mới nhất trước.
List<ActivitySession> sessionsToday(
  List<ActivitySession> all, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final todayStart = DateTime(reference.year, reference.month, reference.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  final result =
      all
          .where(
            (s) =>
                !s.startedAt.isBefore(todayStart) &&
                s.startedAt.isBefore(todayEnd),
          )
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  return result;
}

/// Tổng thời gian (thực, không trừ sao nhãng) của mỗi hoạt động trong danh
/// sách phiên đưa vào — key là activityId.
Map<String, Duration> totalDurationByActivity(List<ActivitySession> sessions) {
  final result = <String, Duration>{};
  for (final s in sessions) {
    result[s.activityId] =
        (result[s.activityId] ?? Duration.zero) + s.totalDuration;
  }
  return result;
}
