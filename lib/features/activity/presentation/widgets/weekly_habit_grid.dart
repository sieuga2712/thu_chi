import 'package:flutter/material.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../models/activity_definition.dart';
import '../../models/activity_icon_catalog.dart';

/// Lưới Tuần: mỗi ngày 1 dòng (Thứ 2 → Chủ nhật), icon các hoạt động
/// checkbox đã tick hôm đó.
class WeeklyHabitGrid extends StatelessWidget {
  const WeeklyHabitGrid({
    super.key,
    required this.days,
    required this.completionsByDay,
    required this.activities,
  });

  final List<DateTime> days;
  final Map<DateTime, List<String>> completionsByDay;
  final List<ActivityDefinition> activities;

  static const _dayLabels = ['THỨ 2', 'THỨ 3', 'THỨ 4', 'THỨ 5', 'THỨ 6', 'THỨ 7', 'CN'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < days.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    _dayLabels[i],
                    style: const TextStyle(
                      fontFamily: RetroStyle.fontFamily,
                      fontSize: 17,
                    ),
                  ),
                ),
                Expanded(child: _IconsForDay(activityIds: completionsByDay[days[i]] ?? const [], activities: activities)),
              ],
            ),
          ),
      ],
    );
  }
}

class _IconsForDay extends StatelessWidget {
  const _IconsForDay({required this.activityIds, required this.activities});

  final List<String> activityIds;
  final List<ActivityDefinition> activities;

  @override
  Widget build(BuildContext context) {
    if (activityIds.isEmpty) {
      return const Text(
        '—',
        style: TextStyle(
          fontFamily: RetroStyle.fontFamily,
          fontSize: 17,
          color: Colors.black26,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: activityIds.map((id) {
        final activity = activities.where((a) => a.id == id).firstOrNull;
        return Tooltip(
          message: activity?.name ?? '(hoạt động đã xóa)',
          child: RetroIconBadge(
            icon: ActivityIconCatalog.iconFor(activity?.icon),
            color: RetroStyle.borderDark,
            size: 30,
            iconSize: 16,
          ),
        );
      }).toList(),
    );
  }
}
