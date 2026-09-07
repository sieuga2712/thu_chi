import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../models/activity_kind.dart';
import '../../../../models/activity_session.dart';
import '../../../../providers/nav_provider.dart';
import '../../../activity/logic/monthly_activity_stats.dart';
import '../../../activity/logic/streak_calculator.dart';
import '../../../activity/providers/activities_provider.dart';
import '../../../activity/providers/activity_sessions_provider.dart';

/// Card "Thành tựu nổi bật" ở Tổng quan — streak dài nhất + tổng số ngày có
/// hoạt động **tính giờ** (kind == timed, không lẫn check-in checkbox).
/// Bấm vào card chuyển sang tab Thành tựu.
class AchievementHighlightCard extends ConsumerWidget {
  const AchievementHighlightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timedIds = ref
        .watch(activitiesProvider)
        .where((a) => a.kind == ActivityKind.timed)
        .map((a) => a.id)
        .toSet();
    final sessions = ref
        .watch(activitySessionsProvider)
        .where((s) => timedIds.contains(s.activityId))
        .toList();

    return InkWell(
      onTap: () => ref.read(navIndexProvider.notifier).set(3),
      child: Container(
        decoration: RetroStyle.panel(),
        padding: const EdgeInsets.all(14),
        child: sessions.isEmpty
            ? _buildEmpty(context)
            : _buildContent(context, sessions),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Row(
      children: [
        const RetroIconBadge(
          icon: Icons.emoji_events_outlined,
          color: Colors.black38,
          size: 36,
          iconSize: 20,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Chưa có thành tựu nào — bắt đầu hoạt động đầu tiên!',
            style: TextStyle(fontFamily: RetroStyle.fontFamily, fontSize: 17),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<ActivitySession> sessions) {
    final streak = computeStreak(sessions);
    final activeDays = totalActiveDays(sessions);

    return Row(
      children: [
        RetroIconBadge(
          icon: Icons.emoji_events,
          color: Colors.amber.shade800,
          size: 36,
          iconSize: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'THÀNH TỰU NỔI BẬT',
                style: TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Streak dài nhất ${streak.longest} ngày • $activeDays ngày có hoạt động',
                style: const TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
