import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/models/activity_definition.dart';
import 'package:thu_chi/models/activity_domain.dart';
import 'package:thu_chi/models/activity_goal_frequency.dart';
import 'package:thu_chi/models/activity_kind.dart';
import 'package:thu_chi/models/activity_supervision_mode.dart';
import 'package:thu_chi/models/activity_timer_type.dart';

void main() {
  test('toJson rồi fromJson giữ nguyên hoạt động checkbox', () {
    const activity = ActivityDefinition(
      id: 'a1',
      name: 'Chuẩn bị đồ đạc',
      domain: ActivityDomain.personal,
      timerType: ActivityTimerType.stopwatch,
      supervisionMode: ActivitySupervisionMode.relaxed,
      kind: ActivityKind.checkbox,
      icon: 'luggage',
      goalFrequency: ActivityGoalFrequency.weekly,
      weeklyGoalCount: 4,
    );

    final result = ActivityDefinition.fromJson(activity.toJson());

    expect(result, activity);
  });

  test('fromJson với dữ liệu cũ (thiếu kind/icon/goalFrequency) coi là hoạt động tính giờ', () {
    // Đúng dạng JSON các hoạt động tạo trước khi có tính năng checkbox.
    final oldJson = {
      'id': 'a1',
      'name': 'Đọc sách',
      'domain': 'learning',
      'timerType': 'stopwatch',
      'countdownMinutes': null,
      'supervisionMode': 'relaxed',
      'isActive': true,
    };

    final result = ActivityDefinition.fromJson(oldJson);

    expect(result.kind, ActivityKind.timed);
    expect(result.icon, isNull);
    expect(result.goalFrequency, isNull);
    expect(result.weeklyGoalCount, isNull);
  });
}
