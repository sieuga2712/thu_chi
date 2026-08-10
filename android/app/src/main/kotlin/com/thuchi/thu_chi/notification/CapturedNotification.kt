package com.thuchi.thu_chi.notification

import org.json.JSONObject

/**
 * Dữ liệu thô trích xuất từ một [android.service.notification.StatusBarNotification]
 * thuộc package được hỗ trợ. Class này cố tình "ngờ nghệch" — không cố diễn giải
 * text thành giao dịch. Việc đó là của TransactionParser bên phía Dart.
 */
data class CapturedNotification(
    val packageName: String,
    val title: String,
    val text: String,
    val bigText: String?,
    val subText: String?,
    val postTimeEpochMillis: Long,
    val capturedAtEpochMillis: Long,
    val notificationKey: String,
) {
    /** Dùng để gửi qua Flutter MethodChannel/EventChannel. */
    fun toMap(): Map<String, Any?> = mapOf(
        "packageName" to packageName,
        "title" to title,
        "text" to text,
        "bigText" to bigText,
        "subText" to subText,
        "postTimeEpochMillis" to postTimeEpochMillis,
        "capturedAtEpochMillis" to capturedAtEpochMillis,
        "notificationKey" to notificationKey,
    )

    /** Dùng để lưu bền vững ở phía native, xem [NotificationStore]. */
    fun toJson(): JSONObject = JSONObject().apply {
        put("packageName", packageName)
        put("title", title)
        put("text", text)
        put("bigText", bigText ?: JSONObject.NULL)
        put("subText", subText ?: JSONObject.NULL)
        put("postTimeEpochMillis", postTimeEpochMillis)
        put("capturedAtEpochMillis", capturedAtEpochMillis)
        put("notificationKey", notificationKey)
    }

    companion object {
        fun fromJson(json: JSONObject): CapturedNotification = CapturedNotification(
            packageName = json.getString("packageName"),
            title = json.optString("title", ""),
            text = json.optString("text", ""),
            bigText = if (json.isNull("bigText")) null else json.optString("bigText"),
            subText = if (json.isNull("subText")) null else json.optString("subText"),
            postTimeEpochMillis = json.getLong("postTimeEpochMillis"),
            capturedAtEpochMillis = json.getLong("capturedAtEpochMillis"),
            notificationKey = json.optString("notificationKey", ""),
        )
    }
}
