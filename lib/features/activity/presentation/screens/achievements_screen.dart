import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../models/activity_definition.dart';
import '../../../../models/activity_kind.dart';
import '../../logic/monthly_activity_stats.dart';
import '../../logic/streak_calculator.dart';
import '../../providers/activities_provider.dart';
import '../../providers/activity_sessions_provider.dart';
import '../widgets/activity_card.dart';
import 'add_activity_screen.dart';

/// Tab "Thành tựu" — nơi sống của hoạt động **tính giờ** (Bắt đầu/Dừng,
/// "tích lũy dần" theo thời gian, ví dụ "Đọc sách"): danh sách điều khiển ở
/// đầu trang, streak + thống kê thời gian bên dưới (chỉ tính hoạt động
/// tính giờ, không lẫn check-in của hoạt động checkbox ở tab Hoạt động).
/// Huy hiệu mốc lớn để làm sau (ngưỡng chưa chốt).
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivities = ref.watch(activitiesProvider);
    final timedActivities = allActivities
        .where((a) => a.kind == ActivityKind.timed)
        .toList();
    final timedIds = timedActivities.map((a) => a.id).toSet();

    final allSessions = ref.watch(activitySessionsProvider);
    final sessions = allSessions
        .where((s) => timedIds.contains(s.activityId))
        .toList();

    final streak = computeStreak(sessions);
    final monthlyTotals = totalDurationThisMonth(sessions);
    final activeDays = totalActiveDays(sessions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('THÀNH TỰU'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm hoạt động tính giờ',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const AddActivityScreen(kind: ActivityKind.timed),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Đang theo dõi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: RetroStyle.fontFamily,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          if (timedActivities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Chưa có hoạt động tính giờ nào — bấm nút + để thêm.',
                style: TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 17,
                ),
              ),
            )
          else
            for (final activity in timedActivities)
              ActivityCard(
                activity: activity,
                onDelete: () => _confirmDelete(context, ref, activity),
              ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Streak hiện tại',
                  value: '${streak.current} ngày',
                  icon: Icons.local_fire_department,
                  color: streak.current > 0
                      ? Colors.deepOrange
                      : Colors.black38,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: 'Streak dài nhất',
                  value: '${streak.longest} ngày',
                  icon: Icons.emoji_events,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatBox(
            label: 'Tổng số ngày có hoạt động',
            value: '$activeDays ngày',
            icon: Icons.calendar_month,
            color: RetroStyle.borderDark,
            fullWidth: true,
          ),
          const SizedBox(height: 20),
          Text(
            'Tháng này',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: RetroStyle.fontFamily,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          if (monthlyTotals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Chưa có hoạt động nào trong tháng này.',
                style: TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 17,
                ),
              ),
            )
          else
            Container(
              decoration: RetroStyle.panel(),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: monthlyTotals.entries.map((entry) {
                  final activity = timedActivities
                      .where((a) => a.id == entry.key)
                      .firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activity?.name ?? '(hoạt động đã xóa)',
                          style: const TextStyle(
                            fontFamily: RetroStyle.fontFamily,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DurationFormatter.format(entry.value),
                          style: const TextStyle(
                            fontFamily: RetroStyle.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ActivityDefinition activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa hoạt động?'),
        content: Text(
          'Hoạt động "${activity.name}" và toàn bộ lịch sử tính giờ của nó sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(activitiesProvider.notifier).delete(activity.id);
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: RetroStyle.panel(),
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          RetroIconBadge(icon: icon, color: color, size: 36, iconSize: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: RetroStyle.fontFamily,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: RetroStyle.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
