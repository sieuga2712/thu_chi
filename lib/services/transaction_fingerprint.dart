import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/transaction.dart';

/// Tính "dấu vân tay" (fingerprint) duy nhất cho một giao dịch, dùng để
/// chống trùng lặp khi cùng một notification bị xử lý nhiều lần (section 6
/// của spec) — ví dụ hệ thống gửi lại notification, hoặc backlog native và
/// stream sống vô tình cùng nhận một notification.
///
/// Dựa trên account + amount + transactionTime + description + balance,
/// đúng như spec đề xuất. Không dùng rawNotification/sourcePackage/id vì
/// những giá trị đó có thể lệch nhẹ giữa hai lần nhận cùng một giao dịch
/// trong khi bản chất giao dịch là một (ví dụ khác notificationKey).
class TransactionFingerprint {
  TransactionFingerprint._();

  static String of(Transaction transaction) {
    return compute(
      account: transaction.account,
      amount: transaction.amount,
      transactionTime: transaction.transactionTime,
      description: transaction.description,
      balanceAfter: transaction.balanceAfter,
    );
  }

  static String compute({
    required String? account,
    required int amount,
    required DateTime transactionTime,
    required String description,
    required int? balanceAfter,
  }) {
    // Chuẩn hoá transactionTime về độ chính xác GIÂY trước khi hash. Drift
    // lưu DateTimeColumn dưới dạng epoch giây (bỏ mili-giây), nên một
    // DateTime "tươi" (vừa parse, còn mili-giây) và cùng DateTime đó sau khi
    // đọc lại từ DB sẽ khác nhau nếu không chuẩn hoá — khiến cùng một giao
    // dịch bị tính ra hai fingerprint khác nhau và chống trùng lặp thất bại.
    final normalizedTime = DateTime(
      transactionTime.year,
      transactionTime.month,
      transactionTime.day,
      transactionTime.hour,
      transactionTime.minute,
      transactionTime.second,
    );

    final raw = [
      account ?? '',
      amount,
      normalizedTime.toIso8601String(),
      description.trim().toLowerCase(),
      balanceAfter ?? '',
    ].join('|');

    return sha256.convert(utf8.encode(raw)).toString();
  }
}
