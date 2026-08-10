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
 *
 * [onNotificationPosted] chỉ bắt được notification MỚI phát sinh sau khi
 * listener đã kết nối — nếu người dùng vừa cấp quyền (hoặc app vừa cấu hình
 * lại [NotificationConfig.SUPPORTED_PACKAGES]) trong khi một notification
 * ngân hàng vẫn đang nằm sẵn trong thanh thông báo, notification đó sẽ KHÔNG
 * tự động được bắt trừ khi được quét chủ động. [onListenerConnected] xử lý
 * đúng trường hợp này bằng [scanActiveNotifications], dùng
 * [getActiveNotifications] để lấy lại những notification đang hiển thị sẵn.
 * An toàn để chạy lại nhiều lần (mỗi lần service reconnect) vì fingerprint
 * unique index (Phase 9) tự loại bỏ trùng lặp.
 */
class BankNotificationListenerService : NotificationListenerService() {

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.i(TAG, "Notification listener connected")
        instance = this
        scanActiveNotifications()
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.i(TAG, "Notification listener disconnected")
        if (instance === this) instance = null
    }

    fun scanActiveNotifications() {
        val active = try {
            activeNotifications
        } catch (e: SecurityException) {
            // Phòng trường hợp gọi trước khi hệ thống thực sự bind xong.
            Log.w(TAG, "Không đọc được active notifications: ${e.message}")
            return
        }
        for (sbn in active) {
            handle(sbn)
        }
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

        /**
         * Tham chiếu tới instance đang được hệ thống bind (null nếu chưa kết
         * nối). Cho phép [NotificationMethodCallHandler] kích hoạt quét thủ
         * công từ Flutter (nút "Quét lại thông báo đang hiển thị" ở Settings)
         * mà không cần tự quản lý binding — NotificationListenerService vốn
         * đã là service duy nhất theo package, không cần AIDL phức tạp.
         */
        @Volatile
        private var instance: BankNotificationListenerService? = null

        /** true nếu đã quét được (tức là listener đang kết nối), false nếu chưa. */
        fun requestRescan(): Boolean {
            val current = instance ?: return false
            current.scanActiveNotifications()
            return true
        }
    }
}
