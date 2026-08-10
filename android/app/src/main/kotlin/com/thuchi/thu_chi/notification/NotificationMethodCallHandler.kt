package com.thuchi.thu_chi.notification

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Xử lý các lệnh gọi một lần từ Flutter qua MethodChannel
 * (NotificationConfig.METHOD_CHANNEL): kiểm tra quyền, mở màn hình cấp
 * quyền, lấy backlog notification đã đệm, và gửi notification thử nghiệm.
 */
class NotificationMethodCallHandler(
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            NotificationConfig.METHOD_IS_NOTIFICATION_ACCESS_GRANTED -> {
                result.success(NotificationAccessUtil.isNotificationAccessGranted(context))
            }

            NotificationConfig.METHOD_OPEN_NOTIFICATION_SETTINGS -> {
                NotificationAccessUtil.openNotificationAccessSettings(context)
                result.success(null)
            }

            NotificationConfig.METHOD_GET_PENDING_NOTIFICATIONS -> {
                val pending = NotificationStore.drain(context).map { it.toMap() }
                result.success(pending)
            }

            NotificationConfig.METHOD_SEND_TEST_NOTIFICATION -> {
                result.success(handleSendTestNotification(call))
            }

            NotificationConfig.METHOD_RESCAN_ACTIVE_NOTIFICATIONS -> {
                // Quét lại các notification NGÂN HÀNG đang hiển thị sẵn trong
                // thanh thông báo (không chỉ notification mới) — hữu ích khi
                // người dùng vừa cấp quyền hoặc vừa cấu hình package trong
                // lúc một notification giao dịch vẫn còn nằm đó. Trả về false
                // nếu listener chưa kết nối (ví dụ chưa cấp quyền).
                result.success(BankNotificationListenerService.requestRescan())
            }

            else -> result.notImplemented()
        }
    }

    /**
     * KHÔNG post một notification thật lên hệ thống: trên Android 13+ việc
     * đó cần quyền runtime POST_NOTIFICATIONS, và dù có post thật thì cũng bị
     * chính bộ lọc [NotificationConfig.SUPPORTED_PACKAGES] chặn lại vì đây là
     * package của chính app, không phải VietinBank.
     *
     * Thay vào đó, mô phỏng trực tiếp một [CapturedNotification] với nội dung
     * do Flutter cung cấp (hoặc mẫu mặc định) và đẩy thẳng qua đúng pipeline
     * lưu trữ + phát event như một notification thật — nhờ vậy có thể kiểm
     * tra toàn bộ luồng parser từ đầu đến cuối ngay trong Settings.
     */
    private fun handleSendTestNotification(call: MethodCall): Boolean {
        val title = call.argument<String>("title") ?: DEFAULT_TEST_TITLE
        val text = call.argument<String>("text") ?: DEFAULT_TEST_TEXT

        val captured = CapturedNotification(
            packageName = TEST_PACKAGE_NAME,
            title = title,
            text = text,
            bigText = null,
            subText = null,
            postTimeEpochMillis = System.currentTimeMillis(),
            capturedAtEpochMillis = System.currentTimeMillis(),
            notificationKey = "test-${System.currentTimeMillis()}",
        )

        NotificationStore.append(context, captured)
        NotificationEventBridge.emit(captured)
        return true
    }

    companion object {
        private const val TEST_PACKAGE_NAME = "com.thuchi.thu_chi.test"
        private const val DEFAULT_TEST_TITLE = "VietinBank"
        private const val DEFAULT_TEST_TEXT =
            "TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A CHUYEN TIEN\nSD: 15,500,000 VND"
    }
}
