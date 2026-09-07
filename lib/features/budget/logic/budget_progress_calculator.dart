import '../../../models/budget_config.dart';
import '../../../models/transaction.dart';
import '../../../models/transaction_type.dart';

/// Tính tổng đã chi trong kỳ hiện tại của [config] từ toàn bộ giao dịch —
/// hàm thuần để dễ unit test, không phụ thuộc DB/thời điểm hệ thống thật.
int computeSpentInCurrentPeriod(
  List<Transaction> allTransactions,
  BudgetConfig config, {
  DateTime? now,
}) {
  final (start, end) = config.period.resolve(now ?? DateTime.now());

  var spent = 0;
  for (final t in allTransactions) {
    if (t.type != TransactionType.expense) continue;
    if (t.transactionTime.isBefore(start) || !t.transactionTime.isBefore(end))
      continue;
    spent += t.amount;
  }
  return spent;
}
