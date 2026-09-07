import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../models/activity_definition.dart';
import '../../../../models/activity_goal_frequency.dart';
import '../../../../models/activity_kind.dart';
import '../../../../models/activity_session.dart';
import '../../../../providers/nav_provider.dart';
import '../../../activity/logic/streak_calculator.dart';
import '../../../activity/logic/today_sessions_calculator.dart';
import '../../../activity/providers/activities_provider.dart';
import '../../../activity/providers/activity_sessions_provider.dart';

/// Card "Hoạt động hôm nay" ở Tổng quan — tổng quan hoạt động **checkbox**
/// (streak, số hoạt động đã tick hôm nay, nút tick nhanh). Bấm vào card
/// (ngoài nút) chuyển sang tab Hoạt động.
class ActivityTodayCard extends ConsumerWidget {
  const ActivityTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref
        .watch(activitiesProvider)
        .where((a) => a.kind == ActivityKind.checkbox)
        .toList();
    final sessions = ref.watch(activitySessionsProvider);

    return InkWell(
      onTap: () => ref.read(navIndexProvider.notifier).set(2),
      child: Container(
        decoration: RetroStyle.panel(),
        padding: const EdgeInsets.all(14),
        child: activities.isEmpty
            ? _buildEmpty(context)
            : _buildContent(context, ref, activities, sessions),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Row(
      children: [
        const RetroIconBadge(
          icon: Icons.checklist,
          color: Colors.black38,
          size: 36,
          iconSize: 20,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Chưa có hoạt động nào — bấm để thêm hoạt động đầu tiên.',
            style: TextStyle(fontFamily: RetroStyle.fontFamily, fontSize: 17),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ActivityDefinition> activities,
    List<ActivitySession> sessions,
  ) {
    final streak = computeStreak(sessions);
    final checkedIdsToday = sessionsToday(
      sessions,
    ).map((s) => s.activityId).toSet();
    final checkedCount = activities
        .where((a) => checkedIdsToday.contains(a.id))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOẠT ĐỘNG HÔM NAY',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontFamily: RetroStyle.fontFamily,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const RetroIconBadge(
              icon: Icons.local_fire_department,
              color: Colors.deepOrange,
              size: 32,
              iconSize: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${streak.current} ngày streak',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const RetroIconBadge(
              icon: Icons.check_circle_outline,
              color: RetroStyle.borderDark,
              size: 32,
              iconSize: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$checkedCount/${activities.length} hoạt động hôm nay',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuickCheckButton(
          ref: ref,
          activities: activities,
          checkedIdsToday: checkedIdsToday,
        ),
      ],
    );
  }
}

class _QuickCheckButton extends StatelessWidget {
  const _QuickCheckButton({
    required this.ref,
    required this.activities,
    required this.checkedIdsToday,
  });

  final WidgetRef ref;
  final List<ActivityDefinition> activities;
  final Set<String> checkedIdsToday;

  @override
  Widget build(BuildContext context) {
    final nextDaily = activities
        .where(
          (a) =>
              a.isActive &&
              a.goalFrequency != ActivityGoalFrequency.weekly &&
              !checkedIdsToday.contains(a.id),
        )
        .firstOrNull;

    if (nextDaily == null) {
      return const Text(
        'Đã tick hết hoạt động hằng ngày hôm nay 🎉',
        style: TextStyle(fontFamily: RetroStyle.fontFamily, fontSize: 16),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () =>
            ref.read(activitySessionsProvider.notifier).checkIn(nextDaily.id),
        icon: const Icon(Icons.check),
        label: Text('Tick nhanh: ${nextDaily.name}'),
      ),
    );
  }
}
