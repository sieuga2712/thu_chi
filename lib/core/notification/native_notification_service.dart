import '../../models/notification_data.dart';
import '../constants/channel_constants.dart';
import 'notification_channel.dart';

/// Lớp bọc toàn bộ giao tiếp Kotlin ↔ Dart cho notification listener.
///
/// Đây là điểm DUY NHẤT trong codebase Dart được phép chạm vào
/// [NotificationChannels]. Các feature khác (Phase 4 trở đi: parser, lưu
/// SQLite, dashboard...) chỉ nên phụ thuộc vào interface này — không phụ
/// thuộc trực tiếp vào MethodChannel/EventChannel — để nếu sau này cần đổi
/// cách giao tiếp native, chỉ phải sửa một chỗ.
class NativeNotificationService {
  const NativeNotificationService();

  /// Stream các notification bắt được theo thời gian thực. CHỈ hoạt động khi
  /// Flutter engine đang chạy (app đang mở foreground). Khi app bị hệ thống
  /// kill hoàn toàn, `BankNotificationListenerService` bên native vẫn tiếp
  /// tục chạy độc lập và tự lưu notification vào hàng đợi native (xem doc ở
  /// class đó và ở `NotificationStore.kt`); dùng [getPendingNotifications]
  /// để lấy lại số đó khi app được mở lại.
  Stream<NotificationData> get notificationStream {
    return NotificationChannels.event.receiveBroadcastStream().map((event) {
      return NotificationData.fromMap(event as Map<Object?, Object?>);
    });
  }

  /// true nếu người dùng đã cấp quyền "Notification access" cho app.
  Future<bool> isNotificationAccessGranted() async {
    final granted = await NotificationChannels.method.invokeMethod<bool>(
      ChannelConstants.methodIsNotificationAccessGranted,
    );
    return granted ?? false;
  }

  /// Mở màn hình Settings hệ thống để người dùng tự cấp quyền
  /// (Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).
  Future<void> openNotificationAccessSettings() async {
    await NotificationChannels.method.invokeMethod<void>(
      ChannelConstants.methodOpenNotificationSettings,
    );
  }

  /// Lấy và xóa toàn bộ notification mà native đã đệm trong lúc Flutter
  /// không chạy hoặc không lắng nghe. Nên gọi mỗi khi app khởi động, trước
  /// khi bắt đầu lắng nghe [notificationStream].
  Future<List<NotificationData>> getPendingNotifications() async {
    final raw = await NotificationChannels.method.invokeMethod<List<Object?>>(
      ChannelConstants.methodGetPendingNotifications,
    );
    if (raw == null) return const [];
    return raw
        .cast<Map<Object?, Object?>>()
        .map(NotificationData.fromMap)
        .toList(growable: false);
  }

  /// Đẩy một notification giả lập qua toàn bộ pipeline (lưu native + phát
  /// event) để kiểm tra parser mà không cần notification VietinBank thật.
  /// Không post notification thật lên hệ thống, nên không cần quyền
  /// POST_NOTIFICATIONS.
  Future<void> sendTestNotification({String? title, String? text}) async {
    await NotificationChannels.method.invokeMethod<void>(
      ChannelConstants.methodSendTestNotification,
      <String, String?>{
        'title': ?title,
        'text': ?text,
      },
    );
  }

  /// Quét lại các notification NGÂN HÀNG đang hiển thị sẵn trong thanh thông
  /// báo (không chỉ notification mới phát sinh) — hữu ích khi người dùng vừa
  /// cấp quyền/cấu hình package trong lúc một notification giao dịch vẫn còn
  /// nằm đó, nếu không thì [onNotificationPosted] sẽ bỏ lỡ nó vĩnh viễn.
  ///
  /// Trả về true nếu quét được (listener đang kết nối), false nếu chưa cấp
  /// quyền notification access.
  Future<bool> rescanActiveNotifications() async {
    final ok = await NotificationChannels.method.invokeMethod<bool>(
      ChannelConstants.methodRescanActiveNotifications,
    );
    return ok ?? false;
  }
}
