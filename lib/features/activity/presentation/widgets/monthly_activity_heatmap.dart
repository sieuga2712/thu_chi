import 'package:flutter/material.dart';

import '../../../../core/theme/retro_style.dart';

/// Lưới nhiệt kiểu GitHub contribution — mỗi ô là 1 ngày trong tháng, đậm
/// nhạt theo tổng thời gian hoạt động ngày đó (so với ngày nhiều nhất trong
/// tháng).
class MonthlyActivityHeatmap extends StatelessWidget {
  const MonthlyActivityHeatmap({
    super.key,
    required this.totalsByDay,
    this.tooltipBuilder,
  });

  final Map<DateTime, Duration> totalsByDay;

  /// Tùy chỉnh nội dung tooltip mỗi ô — mặc định "X phút" (dùng cho hoạt
  /// động tính giờ). Hoạt động checkbox truyền vào hàm hiện "X hoạt động"
  /// (mỗi check-in được quy đổi thành 1 phút danh nghĩa để tái dùng nguyên
  /// widget này).
  final String Function(DateTime day, int minutes)? tooltipBuilder;

  @override
  Widget build(BuildContext context) {
    final days = totalsByDay.keys.toList()..sort();
    if (days.isEmpty) return const SizedBox.shrink();

    final maxMinutes = totalsByDay.values.fold<int>(
      0,
      (max, d) => d.inMinutes > max ? d.inMinutes : max,
    );

    // Căn ô ngày 1 vào đúng cột thứ trong tuần (Thứ 2 = cột đầu).
    final leadingBlanks = days.first.weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (var i = 0; i < leadingBlanks; i++)
              const SizedBox(width: 28, height: 28),
            for (final day in days)
              _HeatmapCell(
                day: day,
                minutes: totalsByDay[day]!.inMinutes,
                maxMinutes: maxMinutes,
                tooltipBuilder: tooltipBuilder,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ít',
              style: TextStyle(
                fontFamily: RetroStyle.fontFamily,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 6),
            for (var level = 0; level <= 4; level++)
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: _levelColor(level, 4),
              ),
            const SizedBox(width: 6),
            const Text(
              'Nhiều',
              style: TextStyle(
                fontFamily: RetroStyle.fontFamily,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Color _levelColor(int level, int maxLevel) {
  if (level == 0) return const Color(0xFFE5E0D0);
  final t = level / maxLevel;
  return Color.lerp(const Color(0xFFB9D9A8), const Color(0xFF16A34A), t)!;
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.day,
    required this.minutes,
    required this.maxMinutes,
    this.tooltipBuilder,
  });

  final DateTime day;
  final int minutes;
  final int maxMinutes;
  final String Function(DateTime day, int minutes)? tooltipBuilder;

  @override
  Widget build(BuildContext context) {
    final level = maxMinutes == 0
        ? 0
        : ((minutes / maxMinutes) * 4).ceil().clamp(0, 4);

    return Tooltip(
      message:
          tooltipBuilder?.call(day, minutes) ??
          '${day.day}/${day.month}: $minutes phút',
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _levelColor(level, 4),
          border: Border.all(color: RetroStyle.borderDark, width: 1),
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 11,
            color: level >= 3 ? Colors.white : RetroStyle.borderDark,
          ),
        ),
      ),
    );
  }
}
