/// Các kiểu lọc thời gian trên Dashboard, xem section 7 của spec.
enum DateRangeType { today, last7Days, thisMonth, lastMonth, custom }

/// Bộ lọc thời gian đang áp dụng cho Dashboard. Với [DateRangeType.custom],
/// [customStart]/[customEnd] phải được cung cấp (do người dùng chọn qua
/// date range picker).
class DateRangeFilter {
  const DateRangeFilter({required this.type, this.customStart, this.customEnd});

  final DateRangeType type;
  final DateTime? customStart;
  final DateTime? customEnd;

  static const initial = DateRangeFilter(type: DateRangeType.thisMonth);

  String get label => switch (type) {
    DateRangeType.today => 'Hôm nay',
    DateRangeType.last7Days => '7 ngày',
    DateRangeType.thisMonth => 'Tháng này',
    DateRangeType.lastMonth => 'Tháng trước',
    DateRangeType.custom => 'Tùy chọn',
  };

  /// Trả về khoảng [start, end) — start bao gồm, end không bao gồm — tính
  /// theo [now] (truyền vào để test dễ, mặc định dùng DateTime.now()).
  (DateTime start, DateTime end) resolve([DateTime? now]) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);

    switch (type) {
      case DateRangeType.today:
        return (today, today.add(const Duration(days: 1)));

      case DateRangeType.last7Days:
        final end = today.add(const Duration(days: 1));
        return (end.subtract(const Duration(days: 7)), end);

      case DateRangeType.thisMonth:
        final start = DateTime(reference.year, reference.month, 1);
        final end = DateTime(reference.year, reference.month + 1, 1);
        return (start, end);

      case DateRangeType.lastMonth:
        final start = DateTime(reference.year, reference.month - 1, 1);
        final end = DateTime(reference.year, reference.month, 1);
        return (start, end);

      case DateRangeType.custom:
        final start =
            customStart ?? DateTime(reference.year, reference.month, 1);
        final endDay = customEnd ?? today;
        final end = DateTime(endDay.year, endDay.month, endDay.day + 1);
        return (start, end);
    }
  }
}
