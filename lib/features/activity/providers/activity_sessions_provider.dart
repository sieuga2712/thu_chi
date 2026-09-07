import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/activity_session.dart';
import '../../../providers/activity_storage_providers.dart';

/// Nguồn dữ liệu phản ứng (reactive) duy nhất cho toàn bộ session hoạt
/// động — cả 2 đường ghi (đồng hồ Dừng ở [ActivityTimerNotifier] và tick
/// checkbox ở đây) đều đi qua notifier này, để UI luôn tự cập nhật ngay sau
/// khi ghi, không phụ thuộc "ăn theo" 1 provider khác đổi state.
class ActivitySessionsNotifier extends Notifier<List<ActivitySession>> {
  @override
  List<ActivitySession> build() {
    return ref.watch(activityStorageServiceProvider).getSessions();
  }

  /// Ghi 1 session đã có sẵn (dùng khi đồng hồ Dừng) — giữ nguyên đường ghi
  /// duy nhất qua storage.
  Future<void> recordSession(ActivitySession session) async {
    await ref.read(activityStorageServiceProvider).addSession(session);
    state = [...state, session];
  }

  DateTime _normalizedDay(DateTime? day) {
    final d = day ?? DateTime.now();
    return DateTime(d.year, d.month, d.day);
  }

  /// Tick 1 hoạt động checkbox cho [day] (mặc định hôm nay) — tạo 1 session
  /// "đánh dấu" (duration = 0) để tái dùng toàn bộ hạ tầng tính toán theo
  /// ngày/tuần/tháng đang có.
  Future<void> checkIn(String activityId, {DateTime? day}) async {
    final normalized = _normalizedDay(day);
    final session = ActivitySession(
      activityId: activityId,
      startedAt: normalized,
      endedAt: normalized,
    );
    await recordSession(session);
  }

  /// Bỏ tick 1 hoạt động checkbox cho [day] (mặc định hôm nay).
  Future<void> checkOut(String activityId, {DateTime? day}) async {
    final normalized = _normalizedDay(day);
    final match = state
        .where(
          (s) =>
              s.activityId == activityId &&
              s.startedAt == normalized &&
              s.endedAt == normalized,
        )
        .firstOrNull;
    if (match == null) return;

    await ref.read(activityStorageServiceProvider).removeSession(match);
    state = state.where((s) => s != match).toList();
  }
}

final activitySessionsProvider =
    NotifierProvider<ActivitySessionsNotifier, List<ActivitySession>>(
      ActivitySessionsNotifier.new,
    );
