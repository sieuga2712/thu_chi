import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/activity_definition.dart';
import '../../../models/activity_domain.dart';
import '../../../models/activity_goal_frequency.dart';
import '../../../models/activity_kind.dart';
import '../../../models/activity_supervision_mode.dart';
import '../../../models/activity_timer_type.dart';
import '../../../providers/activity_storage_providers.dart';

/// Danh sách các hoạt động do người dùng tự định nghĩa.
class ActivitiesNotifier extends Notifier<List<ActivityDefinition>> {
  static const _uuid = Uuid();

  @override
  List<ActivityDefinition> build() {
    final storage = ref.watch(activityStorageServiceProvider);
    return storage.getActivities();
  }

  /// Thêm hoạt động tính giờ (kind mặc định [ActivityKind.timed]).
  Future<void> add({
    required String name,
    required ActivityDomain domain,
    required ActivityTimerType timerType,
    int? countdownMinutes,
    required ActivitySupervisionMode supervisionMode,
  }) async {
    await _addRaw(
      ActivityDefinition(
        id: _uuid.v4(),
        name: name,
        domain: domain,
        timerType: timerType,
        countdownMinutes: countdownMinutes,
        supervisionMode: supervisionMode,
      ),
    );
  }

  /// Thêm hoạt động checkbox — dùng giá trị mặc định vô hại cho các field
  /// chỉ có ý nghĩa với hoạt động tính giờ ([ActivityDomain.personal],
  /// [ActivityTimerType.stopwatch], [ActivitySupervisionMode.relaxed]).
  Future<void> addCheckbox({
    required String name,
    required String icon,
    required ActivityGoalFrequency goalFrequency,
    int? weeklyGoalCount,
  }) async {
    await _addRaw(
      ActivityDefinition(
        id: _uuid.v4(),
        name: name,
        domain: ActivityDomain.personal,
        timerType: ActivityTimerType.stopwatch,
        supervisionMode: ActivitySupervisionMode.relaxed,
        kind: ActivityKind.checkbox,
        icon: icon,
        goalFrequency: goalFrequency,
        weeklyGoalCount: weeklyGoalCount,
      ),
    );
  }

  Future<void> _addRaw(ActivityDefinition activity) async {
    final updated = [...state, activity];
    await ref.read(activityStorageServiceProvider).saveActivities(updated);
    state = updated;
  }

  Future<void> update(ActivityDefinition activity) async {
    final updated = [
      for (final a in state)
        if (a.id == activity.id) activity else a,
    ];
    await ref.read(activityStorageServiceProvider).saveActivities(updated);
    state = updated;
  }

  Future<void> delete(String id) async {
    final updated = state.where((a) => a.id != id).toList();
    await ref.read(activityStorageServiceProvider).saveActivities(updated);
    state = updated;
  }
}

final activitiesProvider =
    NotifierProvider<ActivitiesNotifier, List<ActivityDefinition>>(
      ActivitiesNotifier.new,
    );
