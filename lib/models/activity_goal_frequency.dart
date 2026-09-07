/// Tần suất mục tiêu của 1 hoạt động checkbox.
enum ActivityGoalFrequency {
  /// Tick tự do mỗi ngày, không có mục tiêu số lần.
  daily,

  /// Cần đạt 1 số buổi nhất định trong tuần ([ActivityDefinition.weeklyGoalCount]),
  /// tick ngày nào trong tuần cũng được.
  weekly;

  String get label => switch (this) {
    ActivityGoalFrequency.daily => 'Hằng ngày',
    ActivityGoalFrequency.weekly => 'Theo tuần',
  };
}
