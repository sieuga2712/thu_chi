import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notification/native_notification_service.dart';
import '../models/notification_data.dart';

/// Điểm truy cập duy nhất tới [NativeNotificationService] trong cây provider.
final nativeNotificationServiceProvider = Provider<NativeNotificationService>((ref) {
  return const NativeNotificationService();
});

/// Stream sự kiện notification thời gian thực từ native, dạng thô (chưa
/// parse). Phase 4/5 sẽ lắng nghe provider này để parse + lưu SQLite.
final notificationEventStreamProvider = StreamProvider<NotificationData>((ref) {
  final service = ref.watch(nativeNotificationServiceProvider);
  return service.notificationStream;
});
