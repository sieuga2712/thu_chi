/// Kiểu đồng hồ của một hoạt động.
enum ActivityTimerType {
  /// Đếm lên tự do, dừng khi nào tùy ý.
  stopwatch,

  /// Đếm ngược một khoảng thời gian cố định đặt trước (kiểu Pomodoro).
  countdown;

  String get label => switch (this) {
    ActivityTimerType.stopwatch => 'Đếm lên tự do',
    ActivityTimerType.countdown => 'Đếm ngược cố định',
  };
}
