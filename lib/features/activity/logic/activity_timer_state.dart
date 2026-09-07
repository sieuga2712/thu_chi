import 'package:equatable/equatable.dart';

import '../../../models/active_session.dart';
import '../../../models/activity_definition.dart';

/// Trạng thái đồng hồ hiện tại — [active]/[activity] cùng null nếu không có
/// phiên nào đang chạy (chỉ cho phép tối đa 1 phiên tại một thời điểm).
class ActivityTimerState extends Equatable {
  const ActivityTimerState({
    this.active,
    this.activity,
    this.elapsed = Duration.zero,
    this.distractionElapsed = Duration.zero,
    this.isDistracting = false,
  });

  final ActiveSession? active;
  final ActivityDefinition? activity;
  final Duration elapsed;
  final Duration distractionElapsed;
  final bool isDistracting;

  bool get isRunning => active != null;

  Duration? get countdownRemaining {
    final minutes = activity?.countdownMinutes;
    if (minutes == null) return null;
    final remaining = Duration(minutes: minutes) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  ActivityTimerState copyWith({
    ActiveSession? active,
    ActivityDefinition? activity,
    Duration? elapsed,
    Duration? distractionElapsed,
    bool? isDistracting,
    bool clear = false,
  }) {
    if (clear) return const ActivityTimerState();
    return ActivityTimerState(
      active: active ?? this.active,
      activity: activity ?? this.activity,
      elapsed: elapsed ?? this.elapsed,
      distractionElapsed: distractionElapsed ?? this.distractionElapsed,
      isDistracting: isDistracting ?? this.isDistracting,
    );
  }

  @override
  List<Object?> get props => [
    active,
    activity,
    elapsed,
    distractionElapsed,
    isDistracting,
  ];
}
