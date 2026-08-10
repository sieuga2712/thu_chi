package com.thuchi.thu_chi.notification

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

/**
 * Service được hệ thống bind, nhận mọi notification được post trên thiết bị
 * một khi người dùng cấp quyền Notification Access (Settings.ACTION_
 * NOTIFICATION_LISTENER_SETTINGS). Chỉ những notification có package nằm
 * trong [NotificationConfig.SUPPORTED_PACKAGES] mới được đọc và forward —
 * mọi notification khác (kể cả của chính app này) bị bỏ qua ngay lập tức,
 * trước khi chạm vào bất kỳ nội dung nào của nó.
 *
 * Ghi chú vòng đời (xem thêm doc Phase 3 ở phía Dart):
 * - Service này được hệ thống (NotificationManagerService) khởi động và giữ
 *   sống ngay khi quyền notification access được cấp, độc lập với việc
 *   MainActivity/Flutter engine có đang chạy hay không.
 * - Hệ thống vẫn có thể kill nó khi thiếu bộ nhớ; khi đó nó chỉ đơn giản
 *   được khởi động lại và [onListenerConnected] sẽ chạy lại. Không cần xử lý
 *   START_STICKY thủ công — đó vốn là hành vi mặc định của
 *   NotificationListenerService.
 * - Vì có thể chạy mà không có Flutter engine nào gắn vào, service không bao
 *   giờ được giả định [NotificationEventBridge.listener] đã được set. Mọi
 *   notification luôn được lưu bền vững qua [NotificationStore] trước tiên;
 *   việc forward tới một listener Flutter đang sống chỉ là phần cộng thêm,
 *   làm được thì làm (best-effort).
 */
class BankNotificationListenerService : NotificationListenerService() {

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.i(TAG, "Notification listener connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.i(TAG, "Notification listener disconnected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)
        handle(sbn)
    }

    // Cố tình không override onNotificationRemoved: một notification ngân
    // hàng bị gạt khỏi thanh thông báo không có nghĩa là giao dịch nó báo bị
    // hủy, nên không có gì cần xử lý ở đây.

    private fun handle(sbn: StatusBarNotification) {
        if (sbn.packageName !in NotificationConfig.SUPPORTED_PACKAGES) return

        val captured = extract(sbn) ?: return

        Log.i(TAG, "Captured notification from ${captured.packageName}")

        NotificationStore.append(applicationContext, captured)
        NotificationEventBridge.emit(captured)
    }

    private fun extract(sbn: StatusBarNotification): CapturedNotification? {
        val extras = sbn.notification?.extras ?: return null

        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()

        val hasUsableContent = title.isNotEmpty() || text.isNotEmpty() || !bigText.isNullOrEmpty()
        if (!hasUsableContent) {
            // Ví dụ: notification dạng im lặng/chỉ có progress bar, không có gì để parse.
            return null
        }

        return CapturedNotification(
            packageName = sbn.packageName,
            title = title,
            text = text,
            bigText = bigText,
            subText = subText,
            postTimeEpochMillis = sbn.postTime,
            capturedAtEpochMillis = System.currentTimeMillis(),
            notificationKey = sbn.key,
        )
    }

    companion object {
        private const val TAG = "BankNotifListener"
    }
}
