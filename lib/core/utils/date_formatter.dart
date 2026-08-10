import 'package:intl/intl.dart';

/// Định dạng ngày/giờ dùng chung toàn app, kiểu Việt Nam (dd/MM/yyyy).
class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _dayLabel = DateFormat('dd/MM');
  static final DateFormat _monthLabel = DateFormat('MM/yyyy');

  static String formatDateTime(DateTime time) => _dateTime.format(time);
  static String formatDate(DateTime time) => _date.format(time);

  /// Nhãn ngắn cho trục biểu đồ theo ngày, ví dụ "10/08".
  static String formatDayLabel(DateTime time) => _dayLabel.format(time);

  /// Nhãn ngắn cho trục biểu đồ theo tháng, ví dụ "08/2026".
  static String formatMonthLabel(DateTime time) => _monthLabel.format(time);
}
