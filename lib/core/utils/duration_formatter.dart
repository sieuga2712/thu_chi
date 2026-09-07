/// Định dạng [Duration] kiểu "2 giờ 15 phút" / "45 phút" / "30 giây" — dùng
/// cho hiển thị thời gian hoạt động.
class DurationFormatter {
  DurationFormatter._();

  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return minutes > 0 ? '$hours giờ $minutes phút' : '$hours giờ';
    }
    if (minutes > 0) {
      return '$minutes phút';
    }
    return '$seconds giây';
  }

  /// Dạng đồng hồ đếm "HH:MM:SS" / "MM:SS" — dùng khi đồng hồ đang chạy.
  static String formatClock(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$mm:$ss';
  }
}
