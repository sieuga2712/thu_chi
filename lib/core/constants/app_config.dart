/// Cấu hình tĩnh dùng chung cho toàn app.
///
/// [supportedPackages] KHÔNG được hard-code sẵn một package name đoán mò của
/// VietinBank iPay, vì chưa được xác minh trên thiết bị/APK thật. Hãy điền
/// vào set này (hoặc để người dùng tự thêm package ở màn hình Settings ở
/// phase sau) khi đã biết chính xác package name — ví dụ bằng cách chạy
/// `adb shell dumpsys notification` khi có thông báo VietinBank đang hiện,
/// hoặc kiểm tra manifest của APK đã cài.
///
/// Danh sách tương ứng bên native nằm ở:
/// android/app/src/main/kotlin/com/thuchi/thu_chi/notification/NotificationConfig.kt
/// Luôn giữ đồng bộ hai danh sách này.
class AppConfig {
  AppConfig._();

  static const String appName = 'Thu Chi';

  /// Các package mà notification sẽ được bắt và phân tích.
  /// Đã xác minh trên thiết bị thật qua `adb shell pm list packages | grep vietin`.
  static const Set<String> supportedPackages = <String>{'com.vietinbank.ipay'};

  /// [Transaction.sourcePackage] gán cho giao dịch được người dùng tự thêm
  /// bằng cách dán nội dung thông báo (màn hình "Thêm giao dịch thủ công"),
  /// thay vì bắt tự động qua [NotificationListenerService].
  static const String manualEntrySourcePackage = 'manual';
}
