import 'package:equatable/equatable.dart';

import 'activity_domain.dart';
import 'activity_goal_frequency.dart';
import 'activity_kind.dart';
import 'activity_supervision_mode.dart';
import 'activity_timer_type.dart';

/// Một hoạt động do người dùng tự định nghĩa. Có 2 loại (xem [kind]):
/// - [ActivityKind.timed] (ví dụ "Đọc sách"): dùng [timerType]/
///   [countdownMinutes]/[supervisionMode], sống ở tab Thành tựu.
/// - [ActivityKind.checkbox] (ví dụ "Chuẩn bị đồ đạc"): dùng [icon]/
///   [goalFrequency]/[weeklyGoalCount], sống ở tab Hoạt động. Các field của
///   nhánh [timed] vẫn được set (giá trị mặc định, không dùng tới) để giữ
///   constructor đơn giản, không phải nullable hóa toàn bộ field cũ.
///
/// Lưu tạm bằng JSON qua SharedPreferences ([ActivityStorageService]) trong
/// lúc thiết kế phần "Hoạt động" còn thay đổi — chưa dùng Drift.
class ActivityDefinition extends Equatable {
  const ActivityDefinition({
    required this.id,
    required this.name,
    required this.domain,
    required this.timerType,
    this.countdownMinutes,
    required this.supervisionMode,
    this.isActive = true,
    this.kind = ActivityKind.timed,
    this.icon,
    this.goalFrequency,
    this.weeklyGoalCount,
  });

  final String id;
  final String name;
  final ActivityDomain domain;
  final ActivityTimerType timerType;

  /// Chỉ có giá trị khi [timerType] là [ActivityTimerType.countdown].
  final int? countdownMinutes;

  final ActivitySupervisionMode supervisionMode;
  final bool isActive;

  final ActivityKind kind;

  /// Key trong [ActivityIconCatalog], chỉ dùng khi [kind] là [ActivityKind.checkbox].
  final String? icon;

  /// Chỉ dùng khi [kind] là [ActivityKind.checkbox].
  final ActivityGoalFrequency? goalFrequency;

  /// Số buổi mục tiêu/tuần, chỉ có giá trị khi [goalFrequency] là
  /// [ActivityGoalFrequency.weekly].
  final int? weeklyGoalCount;

  ActivityDefinition copyWith({
    String? name,
    ActivityDomain? domain,
    ActivityTimerType? timerType,
    int? countdownMinutes,
    ActivitySupervisionMode? supervisionMode,
    bool? isActive,
    ActivityKind? kind,
    String? icon,
    ActivityGoalFrequency? goalFrequency,
    int? weeklyGoalCount,
  }) {
    return ActivityDefinition(
      id: id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      timerType: timerType ?? this.timerType,
      countdownMinutes: countdownMinutes ?? this.countdownMinutes,
      supervisionMode: supervisionMode ?? this.supervisionMode,
      isActive: isActive ?? this.isActive,
      kind: kind ?? this.kind,
      icon: icon ?? this.icon,
      goalFrequency: goalFrequency ?? this.goalFrequency,
      weeklyGoalCount: weeklyGoalCount ?? this.weeklyGoalCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'domain': domain.name,
    'timerType': timerType.name,
    'countdownMinutes': countdownMinutes,
    'supervisionMode': supervisionMode.name,
    'isActive': isActive,
    'kind': kind.name,
    'icon': icon,
    'goalFrequency': goalFrequency?.name,
    'weeklyGoalCount': weeklyGoalCount,
  };

  factory ActivityDefinition.fromJson(Map<String, dynamic> json) {
    return ActivityDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: ActivityDomain.values.byName(json['domain'] as String),
      timerType: ActivityTimerType.values.byName(json['timerType'] as String),
      countdownMinutes: json['countdownMinutes'] as int?,
      supervisionMode: ActivitySupervisionMode.values.byName(
        json['supervisionMode'] as String,
      ),
      isActive: json['isActive'] as bool? ?? true,
      // Dữ liệu cũ (trước khi có checkbox) không có field này — coi là
      // hoạt động tính giờ, đúng hành vi trước đây.
      kind: json['kind'] != null
          ? ActivityKind.values.byName(json['kind'] as String)
          : ActivityKind.timed,
      icon: json['icon'] as String?,
      goalFrequency: json['goalFrequency'] != null
          ? ActivityGoalFrequency.values.byName(
              json['goalFrequency'] as String,
            )
          : null,
      weeklyGoalCount: json['weeklyGoalCount'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    domain,
    timerType,
    countdownMinutes,
    supervisionMode,
    isActive,
    kind,
    icon,
    goalFrequency,
    weeklyGoalCount,
  ];
}
