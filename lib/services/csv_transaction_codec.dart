import 'package:csv/csv.dart';

import '../models/transaction.dart';
import '../models/transaction_type.dart';

/// Chuyển đổi danh sách [Transaction] <-> CSV, dùng cho Export/Import dữ liệu
/// thủ công ở Settings (section 10). Không bao gồm id/createdAt vì đó là giá
/// trị do DB tự sinh khi insert lại.
class CsvTransactionCodec {
  CsvTransactionCodec._();

  static const List<String> header = [
    'type',
    'amount',
    'currency',
    'account',
    'description',
    'balanceAfter',
    'transactionTime',
    'transactionCode',
    'sourcePackage',
    'rawNotification',
  ];

  // Dùng \n thay vì mặc định \r\n của package csv, để tránh bị nhân đôi
  // thành \r\r\n khi ghi/đọc file trên Windows (lúc chạy unit test trên desktop).
  static final Csv _codec = Csv(lineDelimiter: '\n');

  static String encode(List<Transaction> transactions) {
    final rows = <List<Object?>>[
      header,
      for (final t in transactions)
        [
          t.type.name,
          t.amount,
          t.currency,
          t.account ?? '',
          t.description,
          t.balanceAfter ?? '',
          t.transactionTime.toIso8601String(),
          t.transactionCode ?? '',
          t.sourcePackage,
          t.rawNotification,
        ],
    ];
    return _codec.encode(rows);
  }

  /// Đọc [Transaction] từ nội dung CSV. Bỏ qua (không throw) những dòng
  /// thiếu trường bắt buộc hoặc sai định dạng, để một file lỗi một phần vẫn
  /// import được phần còn lại.
  static List<Transaction> decode(String csvContent) {
    if (csvContent.trim().isEmpty) return const [];

    final rows = _codec.decodeWithHeaders(csvContent);
    final results = <Transaction>[];
    for (final row in rows) {
      final transaction = _rowToTransaction(row);
      if (transaction != null) results.add(transaction);
    }
    return results;
  }

  static Transaction? _rowToTransaction(CsvRow row) {
    final typeRaw = row['type']?.toString();
    final amountRaw = row['amount']?.toString();
    final timeRaw = row['transactionTime']?.toString();
    if (typeRaw == null || amountRaw == null || timeRaw == null) return null;

    final TransactionType type;
    try {
      type = TransactionType.values.byName(typeRaw);
    } on ArgumentError {
      return null;
    }

    final amount = int.tryParse(amountRaw);
    final time = DateTime.tryParse(timeRaw);
    if (amount == null || time == null) return null;

    final currency = row['currency']?.toString();
    final account = row['account']?.toString();
    final balanceRaw = row['balanceAfter']?.toString();
    final transactionCode = row['transactionCode']?.toString();

    return Transaction(
      type: type,
      amount: amount,
      currency: (currency?.isNotEmpty ?? false) ? currency! : 'VND',
      account: (account?.isNotEmpty ?? false) ? account : null,
      description: row['description']?.toString() ?? '',
      balanceAfter: (balanceRaw?.isNotEmpty ?? false)
          ? int.tryParse(balanceRaw!)
          : null,
      transactionTime: time,
      transactionCode: (transactionCode?.isNotEmpty ?? false)
          ? transactionCode
          : null,
      rawNotification: row['rawNotification']?.toString() ?? '',
      sourcePackage: row['sourcePackage']?.toString() ?? '',
    );
  }
}
