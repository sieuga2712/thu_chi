import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/activity_definition.dart';
import '../../../../models/activity_goal_frequency.dart';
import '../../../../models/activity_kind.dart';
import '../../../../models/activity_session.dart';
import '../../logic/habit_week_stats.dart';
import '../../logic/monthly_heatmap_stats.dart';
import '../../logic/today_sessions_calculator.dart';
import '../../logic/weekly_activity_stats.dart';
import '../../providers/activities_provider.dart';
import '../../providers/activity_sessions_provider.dart';
import '../widgets/habit_checkbox_row.dart';
import '../widgets/monthly_activity_heatmap.dart';
import '../widgets/weekly_habit_grid.dart';
import 'add_activity_screen.dart';

enum _ViewMode { week, month }

/// Tab "Hoạt động" — chỉ còn hoạt động kiểu checkbox (tick xong trong
/// ngày). Hoạt động tính giờ (Bắt đầu/Dừng) đã chuyển sang tab Thành tựu,
/// xem [AchievementsScreen].
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  _ViewMode _viewMode = _ViewMode.week;
  DateTime _weekReference = DateTime.now();

  /// Ngày đang chọn để tick — mặc định hôm nay. Chỉ cho phép hôm nay hoặc
  /// quá khứ (xem [_pickDate]).
  DateTime _selectedDate = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get _isToday => _selectedDate == _today();

  @override
  Widget build(BuildContext context) {
    final allActivities = ref.watch(activitiesProvider);
    final checkboxActivities = allActivities
        .where((a) => a.kind == ActivityKind.checkbox)
        .toList();
    final sessions = ref.watch(activitySessionsProvider);
    final checkedIdsSelected = sessionsToday(
      sessions,
      now: _selectedDate,
    ).map((s) => s.activityId).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HOẠT ĐỘNG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Chọn ngày để tích',
            onPressed: _pickDate,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm hoạt động',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const AddActivityScreen(kind: ActivityKind.checkbox),
              ),
            ),
          ),
        ],
      ),
      body: checkboxActivities.isEmpty
          ? _buildEmpty(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_isToday) ...[
                  Container(
                    decoration: RetroStyle.panel(
                      fill: RetroStyle.accentSelected,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đang tích cho ngày ${AppDateFormatter.formatDate(_selectedDate)}',
                            style: const TextStyle(
                              fontFamily: RetroStyle.fontFamily,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _selectedDate = _today()),
                          child: const Text(
                            'Về hôm nay',
                            style: TextStyle(
                              fontFamily: RetroStyle.fontFamily,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                for (final activity in checkboxActivities)
                  HabitCheckboxRow(
                    activity: activity,
                    checkedToday: checkedIdsSelected.contains(activity.id),
                    weeklyProgress:
                        activity.goalFrequency == ActivityGoalFrequency.weekly
                        ? weeklyCheckInDays(sessions, activity.id)
                        : null,
                    onToggle: () => _toggle(
                      activity,
                      checkedIdsSelected.contains(activity.id),
                    ),
                  ),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<_ViewMode>(
                    segments: const [
                      ButtonSegment(value: _ViewMode.week, label: Text('Tuần')),
                      ButtonSegment(
                        value: _ViewMode.month,
                        label: Text('Tháng'),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (s) =>
                        setState(() => _viewMode = s.first),
                  ),
                ),
                const SizedBox(height: 16),
                switch (_viewMode) {
                  _ViewMode.week => _WeekView(
                    sessions: sessions,
                    activities: checkboxActivities,
                    referenceDate: _weekReference,
                    onPrevWeek: () => setState(
                      () => _weekReference = _weekReference.subtract(
                        const Duration(days: 7),
                      ),
                    ),
                    onNextWeek: () => setState(
                      () => _weekReference = _weekReference.add(
                        const Duration(days: 7),
                      ),
                    ),
                    onResetToCurrentWeek: () =>
                        setState(() => _weekReference = DateTime.now()),
                  ),
                  _ViewMode.month => _MonthView(sessions: sessions),
                },
                SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
              ],
            ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: _today(),
    );
    if (picked == null) return;
    setState(
      () => _selectedDate = DateTime(picked.year, picked.month, picked.day),
    );
  }

  Future<void> _toggle(ActivityDefinition activity, bool checkedAlready) async {
    if (!_isToday) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thay đổi ngày trong quá khứ?'),
          content: Text(
            '${checkedAlready ? 'Bỏ tick' : 'Tick'} "${activity.name}" cho ngày '
            '${AppDateFormatter.formatDate(_selectedDate)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final notifier = ref.read(activitySessionsProvider.notifier);
    if (checkedAlready) {
      await notifier.checkOut(activity.id, day: _selectedDate);
    } else {
      await notifier.checkIn(activity.id, day: _selectedDate);
    }
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checklist, size: 40, color: Colors.black26),
            const SizedBox(height: 12),
            const Text(
              'Chưa có hoạt động nào — bấm nút + để thêm hoạt động đầu tiên.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: RetroStyle.fontFamily, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.sessions,
    required this.activities,
    required this.referenceDate,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onResetToCurrentWeek,
  });

  final List<ActivitySession> sessions;
  final List<ActivityDefinition> activities;
  final DateTime referenceDate;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onResetToCurrentWeek;

  bool get _isCurrentWeek {
    final days = currentWeekDays(now: referenceDate);
    final todayDays = currentWeekDays();
    return days.first == todayDays.first;
  }

  @override
  Widget build(BuildContext context) {
    final days = currentWeekDays(now: referenceDate);
    final completionsByDay = checkboxCompletionsByDay(
      sessions,
      now: referenceDate,
    );
    final weeklyActivities = activities
        .where((a) => a.goalFrequency == ActivityGoalFrequency.weekly)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevWeek,
            ),
            Expanded(
              child: Text(
                '${_formatShort(days.first)} - ${_formatShort(days.last)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextWeek,
            ),
          ],
        ),
        if (!_isCurrentWeek)
          Center(
            child: TextButton(
              onPressed: onResetToCurrentWeek,
              child: const Text(
                'Về tuần này',
                style: TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        WeeklyHabitGrid(
          days: days,
          completionsByDay: completionsByDay,
          activities: activities,
        ),
        if (weeklyActivities.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            decoration: RetroStyle.panel(),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final activity in weeklyActivities)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activity.name,
                          style: const TextStyle(
                            fontFamily: RetroStyle.fontFamily,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${weeklyCheckInDays(sessions, activity.id, now: referenceDate)}/${activity.weeklyGoalCount ?? 0} buổi',
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
            ),
          ),
        ],
      ],
    );
  }

  String _formatShort(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class _MonthView extends StatelessWidget {
  const _MonthView({required this.sessions});

  final List<ActivitySession> sessions;

  @override
  Widget build(BuildContext context) {
    final counts = monthlyCheckInCountsByDay(sessions);

    return MonthlyActivityHeatmap(
      totalsByDay: counts,
      tooltipBuilder: (day, minutes) =>
          '${day.day}/${day.month}: $minutes hoạt động',
    );
  }
}
