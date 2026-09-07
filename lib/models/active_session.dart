import 'package:equatable/equatable.dart';

import 'distraction_interval.dart';

/// Phiên hoạt động đang chạy dở — tách riêng khỏi [ActivitySession] để có
/// thể phục hồi đúng nếu app bị tắt hẳn giữa lúc đồng hồ đang chạy (đọc lại
/// khi mở app, tính elapsed = now - startedAt).
class ActiveSession extends Equatable {
  const ActiveSession({
    required this.activityId,
    required this.startedAt,
    this.pastDistractions = const [],
    this.ongoingDistractionStart,
  });

  final String activityId;
  final DateTime startedAt;

  /// Các đoạn sao nhãng đã kết thúc (rời rồi quay lại) trong phiên này.
  final List<DistractionInterval> pastDistractions;

  /// Mốc bắt đầu của đoạn sao nhãng ĐANG diễn ra (chưa quay lại app), null
  /// nếu hiện không trong đoạn sao nhãng nào.
  final DateTime? ongoingDistractionStart;

  ActiveSession copyWith({
    List<DistractionInterval>? pastDistractions,
    DateTime? ongoingDistractionStart,
    bool clearOngoingDistraction = false,
  }) {
    return ActiveSession(
      activityId: activityId,
      startedAt: startedAt,
      pastDistractions: pastDistractions ?? this.pastDistractions,
      ongoingDistractionStart: clearOngoingDistraction
          ? null
          : (ongoingDistractionStart ?? this.ongoingDistractionStart),
    );
  }

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'startedAt': startedAt.toIso8601String(),
    'pastDistractions': pastDistractions.map((d) => d.toJson()).toList(),
    'ongoingDistractionStart': ongoingDistractionStart?.toIso8601String(),
  };

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      activityId: json['activityId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      pastDistractions: (json['pastDistractions'] as List<dynamic>? ?? [])
          .map((d) => DistractionInterval.fromJson(d as Map<String, dynamic>))
          .toList(),
      ongoingDistractionStart: json['ongoingDistractionStart'] == null
          ? null
          : DateTime.parse(json['ongoingDistractionStart'] as String),
    );
  }

  @override
  List<Object?> get props => [
    activityId,
    startedAt,
    pastDistractions,
    ongoingDistractionStart,
  ];
}
