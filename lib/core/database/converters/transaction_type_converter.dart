import 'package:drift/drift.dart';

import '../../../models/transaction_type.dart';

/// Chuyển đổi [TransactionType] <-> text khi lưu SQLite, để giá trị trong
/// file .db dễ đọc trực tiếp lúc debug (ví dụ "income"/"expense") thay vì số.
class TransactionTypeConverter extends TypeConverter<TransactionType, String> {
  const TransactionTypeConverter();

  @override
  TransactionType fromSql(String fromDb) {
    return TransactionType.values.firstWhere(
      (value) => value.name == fromDb,
      orElse: () => TransactionType.expense,
    );
  }

  @override
  String toSql(TransactionType value) => value.name;
}
