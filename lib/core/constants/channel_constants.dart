/// Các tên dùng chung giữa phía native Kotlin và Dart.
///
/// Phải giữ giống hệt với hằng số khai báo ở:
/// android/app/src/main/kotlin/com/thuchi/thu_chi/notification/NotificationConfig.kt
class ChannelConstants {
  ChannelConstants._();

  /// MethodChannel: các lệnh gọi một lần (kiểm tra quyền, mở settings, lấy backlog).
  static const String methodChannel = 'com.thuchi.thu_chi/notification_method';

  /// EventChannel: luồng sự kiện notification stream từ native listener service.
  static const String eventChannel = 'com.thuchi.thu_chi/notification_events';

  // Tên các method của MethodChannel.
  static const String methodIsNotificationAccessGranted = 'isNotificationAccessGranted';
  static const String methodOpenNotificationSettings = 'openNotificationSettings';
  static const String methodGetPendingNotifications = 'getPendingNotifications';
  static const String methodSendTestNotification = 'sendTestNotification';
}
