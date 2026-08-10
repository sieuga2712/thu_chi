package com.thuchi.thu_chi.notification

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Cầu nối EventChannel (NotificationConfig.EVENT_CHANNEL): khi phía Flutter
 * bắt đầu lắng nghe ([onListen]), gắn một listener vào
 * [NotificationEventBridge] để forward ngay mọi notification bắt được sang
 * Dart dưới dạng Map. Khi Flutter ngừng lắng nghe ([onCancel]) hoặc engine bị
 * hủy, gỡ listener ra — [BankNotificationListenerService] vẫn tiếp tục chạy
 * bình thường và lưu vào [NotificationStore] như khi không có ai lắng nghe.
 *
 * [EventChannel.EventSink.success] bắt buộc phải gọi trên main thread; dùng
 * [mainHandler] để đảm bảo điều đó bất kể notification đến từ thread nào.
 */
class NotificationStreamHandler : EventChannel.StreamHandler {

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        NotificationEventBridge.listener = { notification ->
            mainHandler.post { events.success(notification.toMap()) }
        }
    }

    override fun onCancel(arguments: Any?) {
        NotificationEventBridge.listener = null
    }
}
