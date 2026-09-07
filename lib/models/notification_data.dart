import 'package:equatable/equatable.dart';

/// Dữ liệu thô của một notification nhận từ native, ánh xạ 1-1 với
/// `CapturedNotification.kt` bên phía Kotlin. Chưa được diễn giải thành giao
/// dịch — đó là việc của `TransactionParser` (Phase 4).
class NotificationData extends Equatable {
  const NotificationData({
    required this.packageName,
    required this.title,
    required this.text,
    this.bigText,
    this.subText,
    required this.postTime,
    required this.capturedAt,
    required this.notificationKey,
  });

  final String packageName;
  final String title;
  final String text;
  final String? bigText;
  final String? subText;
  final DateTime postTime;
  final DateTime capturedAt;
  final String notificationKey;

  /// Nội dung "đầy đủ nhất" để đưa vào parser: ưu tiên [bigText] (thường
  /// chứa toàn bộ nội dung khi notification dùng BigTextStyle), nếu không có
  /// thì dùng [text]; ghép thêm [title] và [subText] nếu có.
  String get fullContent {
    final contentLine = (bigText != null && bigText!.isNotEmpty)
        ? bigText!
        : text;
    final parts = <String>[
      if (title.isNotEmpty) title,
      if (contentLine.isNotEmpty) contentLine,
      if (subText != null && subText!.isNotEmpty) subText!,
    ];
    return parts.join('\n');
  }

  factory NotificationData.fromMap(Map<Object?, Object?> map) {
    return NotificationData(
      packageName: map['packageName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      text: map['text'] as String? ?? '',
      bigText: map['bigText'] as String?,
      subText: map['subText'] as String?,
      postTime: DateTime.fromMillisecondsSinceEpoch(
        (map['postTimeEpochMillis'] as num?)?.toInt() ?? 0,
      ),
      capturedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['capturedAtEpochMillis'] as num?)?.toInt() ?? 0,
      ),
      notificationKey: map['notificationKey'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
    packageName,
    title,
    text,
    bigText,
    subText,
    postTime,
    capturedAt,
    notificationKey,
  ];
}
