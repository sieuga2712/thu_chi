import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/active_session.dart';
import '../../../models/activity_definition.dart';
import '../../../models/activity_session.dart';
import '../../../models/activity_supervision_mode.dart';
import '../../../models/distraction_interval.dart';
import '../../../providers/activity_storage_providers.dart';
import '../providers/activity_sessions_provider.dart';
import 'activity_timer_state.dart';

/// Điều khiển đồng hồ hoạt động — chỉ cho phép TỐI ĐA 1 phiên chạy tại một
/// thời điểm. Tick mỗi giây để UI cập nhật thời gian đã trôi qua.
///
/// Chế độ Nghiêm ngặt: dùng [AppLifecycleListener] (Flutter) để biết khi nào
/// app bị đưa xuống nền — CHƯA phân biệt được khóa màn hình và chuyển app
/// khác (xem ghi chú ở [ActivitySupervisionMode.strict]).
class ActivityTimerNotifier extends Notifier<ActivityTimerState> {
  Timer? _ticker;
  AppLifecycleListener? _lifecycleListener;

  @override
  ActivityTimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _lifecycleListener?.dispose();
    });

    final storage = ref.watch(activityStorageServiceProvider);
    final active = storage.getActiveSession();
    if (active == null) return const ActivityTimerState();

    // Phục hồi phiên đang chạy dở (ví dụ app vừa bị tắt hẳn rồi mở lại) —
    // tìm lại ActivityDefinition tương ứng từ danh sách đã lưu.
    final activities = storage.getActivities();
    ActivityDefinition? activity;
    for (final a in activities) {
      if (a.id == active.activityId) {
        activity = a;
        break;
      }
    }
    if (activity == null) {
      // Hoạt động gốc đã bị xóa trong lúc phiên đang chạy — không còn cách
      // nào hiển thị đúng, xóa luôn phiên dở để tránh kẹt trạng thái.
      unawaited(storage.setActiveSession(null));
      return const ActivityTimerState();
    }

    _startTicking();
    if (activity.supervisionMode == ActivitySupervisionMode.strict) {
      _attachLifecycleListener();
    }
    return ActivityTimerState(active: active, activity: activity);
  }

  Future<void> start(ActivityDefinition activity) async {
    if (state.isRunning) return;

    final storage = ref.read(activityStorageServiceProvider);
    final active = ActiveSession(
      activityId: activity.id,
      startedAt: DateTime.now(),
    );
    await storage.setActiveSession(active);

    state = ActivityTimerState(active: active, activity: activity);
    _startTicking();
    if (activity.supervisionMode == ActivitySupervisionMode.strict) {
      _attachLifecycleListener();
    }
  }

  Future<void> stop() async {
    final active = state.active;
    if (active == null) return;

    _ticker?.cancel();
    _ticker = null;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;

    final now = DateTime.now();
    var distractions = active.pastDistractions;
    if (active.ongoingDistractionStart != null) {
      distractions = [
        ...distractions,
        DistractionInterval(start: active.ongoingDistractionStart!, end: now),
      ];
    }

    await ref
        .read(activitySessionsProvider.notifier)
        .recordSession(
          ActivitySession(
            activityId: active.activityId,
            startedAt: active.startedAt,
            endedAt: now,
            distractions: distractions,
          ),
        );
    await ref.read(activityStorageServiceProvider).setActiveSession(null);

    state = const ActivityTimerState();
  }

  void _startTicking() {
    _ticker?.cancel();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final active = state.active;
    final activity = state.activity;
    if (active == null || activity == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(active.startedAt);

    var distractionTotal = active.pastDistractions.fold<Duration>(
      Duration.zero,
      (sum, d) => sum + d.duration,
    );
    if (active.ongoingDistractionStart != null) {
      distractionTotal += now.difference(active.ongoingDistractionStart!);
    }

    state = state.copyWith(
      elapsed: elapsed,
      distractionElapsed: distractionTotal,
      isDistracting: active.ongoingDistractionStart != null,
    );

    final countdownMinutes = activity.countdownMinutes;
    if (countdownMinutes != null &&
        elapsed >= Duration(minutes: countdownMinutes)) {
      unawaited(stop());
    }
  }

  void _attachLifecycleListener() {
    _lifecycleListener?.dispose();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (lifecycleState) {
        if (lifecycleState == AppLifecycleState.paused) {
          _beginDistraction();
        } else if (lifecycleState == AppLifecycleState.resumed) {
          _endDistraction();
        }
      },
    );
  }

  void _beginDistraction() {
    final active = state.active;
    if (active == null || active.ongoingDistractionStart != null) return;

    final updated = active.copyWith(ongoingDistractionStart: DateTime.now());
    state = state.copyWith(active: updated);
    unawaited(
      ref.read(activityStorageServiceProvider).setActiveSession(updated),
    );
  }

  void _endDistraction() {
    final active = state.active;
    if (active == null || active.ongoingDistractionStart == null) return;

    final closed = DistractionInterval(
      start: active.ongoingDistractionStart!,
      end: DateTime.now(),
    );
    final updated = active.copyWith(
      pastDistractions: [...active.pastDistractions, closed],
      clearOngoingDistraction: true,
    );
    state = state.copyWith(active: updated);
    unawaited(
      ref.read(activityStorageServiceProvider).setActiveSession(updated),
    );
  }
}

final activityTimerProvider =
    NotifierProvider<ActivityTimerNotifier, ActivityTimerState>(
      ActivityTimerNotifier.new,
    );
