import '../../../models/activity_session.dart';
import 'weekly_activity_stats.dart';

/// Danh sách activityId đã tick trong mỗi ngày của tuần chứa [now] — dùng
/// vẽ lưới Tuần (mỗi ngày 1 dòng, icon các hoạt động đã tick). Luôn trả đủ
/// 7 ngày (Thứ 2 → Chủ nhật), ngày chưa tick gì thì danh sách rỗng.
Map<DateTime, List<String>> checkboxCompletionsByDay(
  List<ActivitySession> sessions, {
  DateTime? now,
}) {
  final days = currentWeekDays(now: now);
  final result = <DateTime, List<String>>{for (final d in days) d: []};

  final weekStart = days.first;
  final weekEnd = days.last.add(const Duration(days: 1));

  for (final s in sessions) {
    if (s.startedAt.isBefore(weekStart) || !s.startedAt.isBefore(weekEnd)) {
      continue;
    }
    final day = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
    final activityIds = result[day];
    if (activityIds == null) continue;
    if (!activityIds.contains(s.activityId)) {
      activityIds.add(s.activityId);
    }
  }

  return result;
}

/// Số ngày khác nhau trong tuần chứa [now] mà [activityId] có ít nhất 1
/// check-in — dùng hiển thị tiến độ "X/mục tiêu buổi tuần này" cho hoạt
/// động tần suất Theo tuần.
int weeklyCheckInDays(
  List<ActivitySession> sessions,
  String activityId, {
  DateTime? now,
}) {
  final days = currentWeekDays(now: now);
  final weekStart = days.first;
  final weekEnd = days.last.add(const Duration(days: 1));

  final checkedDays = <DateTime>{};
  for (final s in sessions) {
    if (s.activityId != activityId) continue;
    if (s.startedAt.isBefore(weekStart) || !s.startedAt.isBefore(weekEnd)) {
      continue;
    }
    checkedDays.add(
      DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day),
    );
  }
  return checkedDays.length;
}
