import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/notification_providers.dart';

/// Trạng thái quyền "Notification access". autoDispose để luôn lấy giá trị
/// mới mỗi khi Settings screen được mount lại hoặc bị invalidate thủ công
/// (sau khi người dùng quay lại từ màn hình Settings hệ thống).
final notificationAccessGrantedProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final service = ref.watch(nativeNotificationServiceProvider);
  return service.isNotificationAccessGranted();
});
