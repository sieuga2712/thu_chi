import 'package:thu_chi/core/notification/native_notification_service.dart';
import 'package:thu_chi/models/notification_data.dart';

/// Bản giả của [NativeNotificationService] dùng cho test, không chạm vào
/// MethodChannel/EventChannel thật (không có platform channel trong môi
/// trường `flutter test`).
class FakeNativeNotificationService implements NativeNotificationService {
  bool grantedOverride = false;
  List<NotificationData> pendingOverride = const [];
  int openSettingsCallCount = 0;
  int sendTestNotificationCallCount = 0;

  @override
  Future<bool> isNotificationAccessGranted() async => grantedOverride;

  @override
  Future<void> openNotificationAccessSettings() async {
    openSettingsCallCount++;
  }

  @override
  Future<List<NotificationData>> getPendingNotifications() async => pendingOverride;

  @override
  Future<void> sendTestNotification({String? title, String? text}) async {
    sendTestNotificationCallCount++;
  }

  @override
  Stream<NotificationData> get notificationStream => const Stream.empty();
}
