package com.thuchi.thu_chi.notification

/**
 * Bản sao phía native, tương ứng với:
 * - lib/core/constants/app_config.dart (SUPPORTED_PACKAGES)
 * - lib/core/constants/channel_constants.dart (tên channel/method)
 *
 * Luôn giữ đồng bộ hai file khi sửa bất kỳ file nào.
 */
object NotificationConfig {

    /**
     * Các package name mà notification sẽ được bắt và gửi sang Flutter.
     * Để trống cho đến khi xác minh chính xác package name của VietinBank
     * iPay (ví dụ: chạy `adb shell dumpsys notification` khi có thông báo
     * giao dịch thật đang hiện, hoặc `adb shell pm list packages | grep vietin`).
     * KHÔNG được đoán mò package name ở đây.
     */
    val SUPPORTED_PACKAGES: Set<String> = setOf(
        // "com.vietinbank.ipay", // TODO: thay bằng package name đã xác minh
    )

    const val METHOD_CHANNEL = "com.thuchi.thu_chi/notification_method"
    const val EVENT_CHANNEL = "com.thuchi.thu_chi/notification_events"

    const val METHOD_IS_NOTIFICATION_ACCESS_GRANTED = "isNotificationAccessGranted"
    const val METHOD_OPEN_NOTIFICATION_SETTINGS = "openNotificationSettings"
    const val METHOD_GET_PENDING_NOTIFICATIONS = "getPendingNotifications"
    const val METHOD_SEND_TEST_NOTIFICATION = "sendTestNotification"

    /** Số lượng notification tối đa được đệm ở phía native khi Flutter chưa chạy. */
    const val MAX_PENDING_QUEUE_SIZE = 200

    const val PREFS_NAME = "bank_notification_store"
    const val PREFS_KEY_PENDING_QUEUE = "pending_queue"
}
