package com.thuchi.thu_chi

import com.thuchi.thu_chi.notification.NotificationConfig
import com.thuchi.thu_chi.notification.NotificationMethodCallHandler
import com.thuchi.thu_chi.notification.NotificationStreamHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Chỉ chịu trách nhiệm gắn (wire) các channel notification vào Flutter
 * engine mỗi khi engine được tạo. Toàn bộ logic thật sự nằm trong
 * NotificationMethodCallHandler/NotificationStreamHandler (package
 * `notification`) để MainActivity luôn gọn, dễ mở rộng thêm channel khác sau này.
 *
 * Lưu ý: [configureFlutterEngine] chỉ chạy khi có một FlutterEngine gắn với
 * Activity này (app đang ở foreground, hoặc vừa được mở). Nó KHÔNG chạy khi
 * app bị đóng hoàn toàn — lúc đó BankNotificationListenerService vẫn chạy
 * độc lập (xem doc ở class đó) và tự lưu notification vào hàng đợi native,
 * chờ được đọc qua getPendingNotifications ở lần configureFlutterEngine kế tiếp.
 */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NotificationConfig.METHOD_CHANNEL,
        ).setMethodCallHandler(NotificationMethodCallHandler(applicationContext))

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NotificationConfig.EVENT_CHANNEL,
        ).setStreamHandler(NotificationStreamHandler())
    }
}
