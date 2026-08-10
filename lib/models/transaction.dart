import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

/// Model miền (domain model) cho một giao dịch đã được [TransactionParser]
/// trích xuất từ notification. Đây KHÔNG phải entity của Drift — Phase 5
/// định nghĩa bảng SQLite riêng (`TransactionRow`) và map qua/lại với class
/// này ở `DriftTransactionRepository`.
class Transaction extends Equatable {
  const Transaction({
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.transactionTime,
    required this.rawNotification,
    required this.sourcePackage,
    this.id,
    this.account,
    this.balanceAfter,
    this.transactionCode,
  });

  /// null với giao dịch mới được parser tạo ra, chưa lưu vào SQLite; có giá
  /// trị khi đọc lại từ [TransactionRepository].
  final int? id;

  final TransactionType type;

  /// Số tiền, đơn vị nguyên của [currency] (VND trong thực tế không có phần
  /// thập phân trên notification ngân hàng).
  final int amount;
  final String currency;

  /// Số tài khoản đã che (ví dụ "****1234"), null nếu không trích xuất được.
  final String? account;
  final String description;

  /// Số dư sau giao dịch, null nếu notification không cung cấp.
  final int? balanceAfter;
  final DateTime transactionTime;

  /// Mã giao dịch nếu notification có cung cấp (ví dụ "Ref: FT26224xxxxx").
  final String? transactionCode;

  /// Toàn bộ nội dung notification gốc (đã ghép title + text/bigText +
  /// subText) — dùng để debug parser, xem section 5 của spec.
  final String rawNotification;
  final String sourcePackage;

  Transaction copyWith({int? id}) {
    return Transaction(
      id: id ?? this.id,
      type: type,
      amount: amount,
      currency: currency,
      account: account,
      description: description,
      balanceAfter: balanceAfter,
      transactionTime: transactionTime,
      transactionCode: transactionCode,
      rawNotification: rawNotification,
      sourcePackage: sourcePackage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        currency,
        account,
        description,
        balanceAfter,
        transactionTime,
        transactionCode,
        rawNotification,
        sourcePackage,
      ];
}
