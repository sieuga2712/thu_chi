package com.thuchi.thu_chi.notification

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings

/**
 * Các hàm hỗ trợ xử lý quyền đặc biệt "Notification access". Đây không phải
 * runtime permission (không có dialog hệ thống) — người dùng phải tự bật ở
 * màn hình Settings hệ thống, được mở bởi [openNotificationAccessSettings].
 */
object NotificationAccessUtil {

    private const val ENABLED_NOTIFICATION_LISTENERS_SETTING = "enabled_notification_listeners"

    fun componentName(context: Context): ComponentName =
        ComponentName(context, BankNotificationListenerService::class.java)

    /**
     * Làm lại đúng cách kiểm tra mà `NotificationManagerCompat.getEnabledListenerPackages`
     * thực hiện bên trong, nhưng không cần thêm dependency androidx.core:
     * danh sách listener đã bật được lưu dưới dạng chuỗi các ComponentName
     * (dạng flatten) ngăn cách bởi ':' trong một key của Settings.Secure.
     */
    fun isNotificationAccessGranted(context: Context): Boolean {
        val target = componentName(context)
        val flat = Settings.Secure.getString(
            context.contentResolver,
            ENABLED_NOTIFICATION_LISTENERS_SETTING,
        ) ?: return false

        return flat.split(":").any { raw ->
            raw.isNotEmpty() && ComponentName.unflattenFromString(raw) == target
        }
    }

    fun openNotificationAccessSettings(context: Context) {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }
}
