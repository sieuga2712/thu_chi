import 'package:flutter/material.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../models/activity_definition.dart';
import '../../../../models/activity_goal_frequency.dart';
import '../../models/activity_icon_catalog.dart';

/// Một dòng hoạt động checkbox — bấm cả dòng để tick/bỏ tick hôm nay.
/// Hoạt động tần suất "Theo tuần" hiện thêm dòng phụ "X/Y buổi tuần này".
class HabitCheckboxRow extends StatelessWidget {
  const HabitCheckboxRow({
    super.key,
    required this.activity,
    required this.checkedToday,
    required this.onToggle,
    this.weeklyProgress,
  });

  final ActivityDefinition activity;
  final bool checkedToday;
  final VoidCallback onToggle;

  /// Số buổi đã đạt trong tuần này — chỉ có giá trị khi
  /// `activity.goalFrequency == ActivityGoalFrequency.weekly`.
  final int? weeklyProgress;

  @override
  Widget build(BuildContext context) {
    final isWeekly = activity.goalFrequency == ActivityGoalFrequency.weekly;

    return InkWell(
      onTap: onToggle,
      child: Container(
        decoration: RetroStyle.panel(
          fill: checkedToday ? RetroStyle.accentSelected : RetroStyle.panelFill,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            RetroIconBadge(
              icon: ActivityIconCatalog.iconFor(activity.icon),
              color: RetroStyle.borderDark,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.name,
                    style: const TextStyle(
                      fontFamily: RetroStyle.fontFamily,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isWeekly)
                    Text(
                      '${weeklyProgress ?? 0}/${activity.weeklyGoalCount ?? 0} buổi tuần này',
                      style: const TextStyle(
                        fontFamily: RetroStyle.fontFamily,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              checkedToday ? Icons.check_circle : Icons.radio_button_unchecked,
              color: checkedToday ? RetroStyle.borderDark : Colors.black26,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
