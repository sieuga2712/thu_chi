import 'package:equatable/equatable.dart';

import 'distraction_interval.dart';

/// Một phiên hoạt động ĐÃ hoàn thành (đã bấm Dừng) — khác với phiên đang
/// chạy dở, xem [ActiveSession].
class ActivitySession extends Equatable {
  const ActivitySession({
    required this.activityId,
    required this.startedAt,
    required this.endedAt,
    this.distractions = const [],
  });

  final String activityId;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<DistractionInterval> distractions;

  Duration get totalDuration => endedAt.difference(startedAt);

  Duration get totalDistraction => distractions.fold(
    Duration.zero,
    (sum, d) => sum + d.duration,
  );

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'distractions': distractions.map((d) => d.toJson()).toList(),
  };

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      activityId: json['activityId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      distractions: (json['distractions'] as List<dynamic>? ?? [])
          .map((d) => DistractionInterval.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [activityId, startedAt, endedAt, distractions];
}
