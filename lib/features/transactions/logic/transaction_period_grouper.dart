import '../../../models/transaction.dart';
import '../../../models/transaction_type.dart';

/// Tổng hợp giao dịch trong 1 khoảng thời gian (ngày/tuần/tháng) — dùng
/// chung cho cả 3 chế độ xem "Ngày/Tuần/Tháng" ở màn hình Giao dịch.
class PeriodTransactionGroup {
  const PeriodTransactionGroup({
    required this.start,
    required this.end,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  /// Đầu khoảng thời gian (inclusive, đã chuẩn hóa về 00:00).
  final DateTime start;

  /// Cuối khoảng thời gian (exclusive).
  final DateTime end;

  /// Giao dịch trong khoảng, mới nhất trước.
  final List<Transaction> transactions;
  final int totalIncome;
  final int totalExpense;
}

List<PeriodTransactionGroup> _groupByPeriod(
  List<Transaction> transactions,
  DateTime Function(DateTime time) periodStart,
  DateTime Function(DateTime start) periodEnd,
) {
  final byPeriod = <DateTime, List<Transaction>>{};
  for (final t in transactions) {
    final start = periodStart(t.transactionTime);
    byPeriod.putIfAbsent(start, () => []).add(t);
  }

  final groups = byPeriod.entries.map((entry) {
    final periodTransactions = entry.value
      ..sort((a, b) => b.transactionTime.compareTo(a.transactionTime));
    var income = 0;
    var expense = 0;
    for (final t in periodTransactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return PeriodTransactionGroup(
      start: entry.key,
      end: periodEnd(entry.key),
      transactions: periodTransactions,
      totalIncome: income,
      totalExpense: expense,
    );
  }).toList();

  groups.sort((a, b) => b.start.compareTo(a.start));
  return groups;
}

/// Gom theo từng ngày, ngày mới nhất trước.
List<PeriodTransactionGroup> groupTransactionsByDay(
  List<Transaction> transactions,
) {
  return _groupByPeriod(
    transactions,
    (time) => DateTime(time.year, time.month, time.day),
    (start) => start.add(const Duration(days: 1)),
  );
}

/// Gom theo từng tuần (bắt đầu Thứ 2, kiểu ISO 8601), tuần mới nhất trước.
List<PeriodTransactionGroup> groupTransactionsByWeek(
  List<Transaction> transactions,
) {
  return _groupByPeriod(
    transactions,
    (time) {
      final day = DateTime(time.year, time.month, time.day);
      return day.subtract(Duration(days: day.weekday - 1));
    },
    (start) => start.add(const Duration(days: 7)),
  );
}

/// Gom theo từng tháng, tháng mới nhất trước.
List<PeriodTransactionGroup> groupTransactionsByMonth(
  List<Transaction> transactions,
) {
  return _groupByPeriod(
    transactions,
    (time) => DateTime(time.year, time.month, 1),
    (start) => DateTime(start.year, start.month + 1, 1),
  );
}
