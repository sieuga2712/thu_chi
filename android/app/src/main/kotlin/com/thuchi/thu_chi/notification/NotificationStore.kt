package com.thuchi.thu_chi.notification

import android.content.Context
import org.json.JSONArray
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

/**
 * Hàng đợi bền vững phía native cho các notification đã bắt được.
 *
 * [BankNotificationListenerService] được hệ thống khởi động và giữ sống độc
 * lập với Flutter engine (xem doc ở class đó). Mỗi notification bắt được sẽ
 * được append vào đây trước tiên, để không mất dữ liệu nếu Flutter/activity
 * chưa chạy hoặc chưa lắng nghe tại thời điểm đó. Phía Dart sẽ rút hết hàng
 * đợi này qua MethodChannel `getPendingNotifications` vào lần app khởi động
 * tiếp theo (xem NotificationConfig.METHOD_GET_PENDING_NOTIFICATIONS), sau đó
 * hàng đợi được xóa sạch.
 *
 * Lưu trữ bằng SharedPreferences: một chuỗi JSON-array nhỏ duy nhất, giới hạn
 * tối đa [NotificationConfig.MAX_PENDING_QUEUE_SIZE] phần tử (bỏ phần tử cũ
 * nhất trước). Chỉ lưu title/text thô của notification — không bao giờ lưu
 * thông tin đăng nhập ngân hàng hay OTP, vì app không bao giờ yêu cầu những
 * thứ đó ngay từ đầu.
 */
object NotificationStore {

    private val lock = ReentrantLock()

    private fun prefs(context: Context) =
        context.getSharedPreferences(NotificationConfig.PREFS_NAME, Context.MODE_PRIVATE)

    fun append(context: Context, notification: CapturedNotification) = lock.withLock {
        val prefs = prefs(context)
        val existing = JSONArray(prefs.getString(NotificationConfig.PREFS_KEY_PENDING_QUEUE, "[]"))
        existing.put(notification.toJson())

        val overflow = existing.length() - NotificationConfig.MAX_PENDING_QUEUE_SIZE
        val result = if (overflow > 0) {
            val trimmed = JSONArray()
            for (i in overflow until existing.length()) {
                trimmed.put(existing.get(i))
            }
            trimmed
        } else {
            existing
        }

        prefs.edit().putString(NotificationConfig.PREFS_KEY_PENDING_QUEUE, result.toString()).apply()
    }

    /** Trả về và xóa toàn bộ notification đang đệm. */
    fun drain(context: Context): List<CapturedNotification> = lock.withLock {
        val prefs = prefs(context)
        val array = JSONArray(prefs.getString(NotificationConfig.PREFS_KEY_PENDING_QUEUE, "[]"))
        val result = (0 until array.length()).map { i ->
            CapturedNotification.fromJson(array.getJSONObject(i))
        }
        prefs.edit().putString(NotificationConfig.PREFS_KEY_PENDING_QUEUE, "[]").apply()
        result
    }
}
