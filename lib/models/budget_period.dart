/// Kỳ áp dụng của ngân sách — luôn tính theo kỳ **hiện tại** (không có kỳ
/// tùy chọn/quá khứ), tự "chuyển" sang kỳ mới khi ngày thay đổi vì
/// [resolve] luôn tính lại từ [DateTime.now] chứ không lưu trạng thái.
enum BudgetPeriod {
  day,
  week,
  month;

  String get label => switch (this) {
    BudgetPeriod.day => 'Ngày',
    BudgetPeriod.week => 'Tuần',
    BudgetPeriod.month => 'Tháng',
  };

  /// Khoảng [start, end) của kỳ hiện tại chứa [now]. Tuần bắt đầu từ Thứ 2.
  (DateTime start, DateTime end) resolve(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case BudgetPeriod.day:
        return (today, today.add(const Duration(days: 1)));
      case BudgetPeriod.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return (start, start.add(const Duration(days: 7)));
      case BudgetPeriod.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start, end);
    }
  }
}
