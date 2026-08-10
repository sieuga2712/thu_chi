# Thu Chi

Ứng dụng Flutter (Android) đọc thông báo biến động số dư từ **VietinBank iPay** ngay trên thiết bị, tự động phân tích và thống kê thu chi — hoàn toàn **offline, local-only**.

## Nguyên tắc cốt lõi

- **Không** đăng nhập VietinBank, không gọi API ngân hàng.
- **Không** lưu username/password/OTP ngân hàng.
- **Không** gửi dữ liệu giao dịch lên bất kỳ server nào.
- Toàn bộ dữ liệu chỉ lưu trong SQLite local trên máy (qua [Drift](https://drift.simonbinder.eu)).
- Hoạt động offline hoàn toàn.

Luồng dữ liệu:

```
VietinBank iPay
   → Android NotificationListenerService (Kotlin)
   → EventChannel/MethodChannel
   → Flutter (TransactionParser)
   → SQLite (Drift)
   → Dashboard / Danh sách giao dịch
```

## Cấu hình package name VietinBank

Package name của VietinBank iPay **chưa được xác minh** và để trống mặc định — ứng dụng sẽ không bắt notification nào cho đến khi cấu hình. Cập nhật ở **cả hai** nơi sau (phải giống nhau):

- `lib/core/constants/app_config.dart` → `AppConfig.supportedPackages`
- `android/app/src/main/kotlin/com/thuchi/thu_chi/notification/NotificationConfig.kt` → `SUPPORTED_PACKAGES`

Cách tìm package name chính xác: `adb shell dumpsys notification` khi có thông báo VietinBank đang hiện, hoặc `adb shell pm list packages | grep -i vietin`.

## Chạy dự án

```bash
flutter pub get
dart run build_runner build   # sinh code Drift (app_database.g.dart)
flutter run
```

## Kiến trúc thư mục

```
lib/
├── core/           # constants, database (Drift), notification channel, theme, utils
├── features/       # dashboard, transactions, settings, notification_access (mỗi feature: models/providers/presentation)
├── models/         # domain model dùng chung (Transaction, NotificationData, ...)
├── repositories/   # TransactionRepository (interface) + DriftTransactionRepository
├── services/       # TransactionParser, NotificationPipelineService, TransactionFingerprint, CSV codec
└── providers/      # Riverpod provider dùng chung toàn app

android/app/src/main/kotlin/.../notification/
├── BankNotificationListenerService.kt   # đọc notification hệ thống
├── NotificationConfig.kt                # config package name + tên channel
├── NotificationStore.kt                 # hàng đợi bền vững khi Flutter chưa chạy
├── NotificationEventBridge.kt           # cầu nối service <-> EventChannel
├── NotificationStreamHandler.kt         # EventChannel.StreamHandler
├── NotificationMethodCallHandler.kt     # MethodChannel handler
└── NotificationAccessUtil.kt            # kiểm tra/mở quyền Notification access
```

## Test

```bash
flutter test
flutter analyze
```

## Ghi chú kỹ thuật

- `sqlite3` v3.x tự bundle thư viện native qua Dart hooks/native-assets — không cần `sqlite3_flutter_libs` hay workaround thủ công cho Android.
- Chống trùng lặp giao dịch dựa trên fingerprint SHA-256 (`account + amount + transactionTime + description + balance`), enforce bằng unique index + `insertOrIgnore` ở tầng SQLite.
- `tool/inspect_db.dart`: script debug đọc trực tiếp file SQLite đã kéo từ thiết bị (`dart run tool/inspect_db.dart <path-to-db>`).
