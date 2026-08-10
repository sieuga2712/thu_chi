package com.thuchi.thu_chi.notification

/**
 * Cầu nối in-process giữa [BankNotificationListenerService] (do hệ thống quản
 * lý, chạy độc lập với Flutter engine) và phía Flutter.
 *
 * Khi Flutter đang chạy và đang lắng nghe (gắn ở Phase 3 qua EventChannel,
 * xem MainActivity), [listener] sẽ được set và mỗi notification bắt được sẽ
 * được forward ngay lập tức để cập nhật UI theo thời gian thực. Khi nó là
 * null — Flutter chưa chạy, hoặc chưa subscribe — service đã lưu bền vững
 * notification đó qua [NotificationStore] rồi, nên không mất dữ liệu; nó sẽ
 * được rút ra ở lần mở app tiếp theo.
 */
object NotificationEventBridge {

    var listener: ((CapturedNotification) -> Unit)? = null

    fun emit(notification: CapturedNotification) {
        listener?.invoke(notification)
    }
}
