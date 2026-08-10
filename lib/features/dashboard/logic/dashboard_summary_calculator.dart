import '../../../models/transaction.dart';
import '../../../models/transaction_type.dart';
import '../models/dashboard_summary.dart';
import '../models/date_range_filter.dart';

/// Tính [DashboardSummary] từ toàn bộ giao dịch đã lưu + bộ lọc đang chọn.
/// Là hàm thuần (pure function) để dễ unit test độc lập với Drift/DB.
DashboardSummary computeDashboardSummary(
  List<Transaction> allTransactions,
  DateRangeFilter filter, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final (start, end) = filter.resolve(reference);

  final inRange = allTransactions
      .where((t) => !t.transactionTime.isBefore(start) && t.transactionTime.isBefore(end))
      .toList(growable: false);

  var totalIncome = 0;
  var totalExpense = 0;
  for (final t in inRange) {
    if (t.type == TransactionType.income) {
      totalIncome += t.amount;
    } else {
      totalExpense += t.amount;
    }
  }

  final recent = List<Transaction>.of(allTransactions)
    ..sort((a, b) => b.transactionTime.compareTo(a.transactionTime));

  return DashboardSummary(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    transactionCount: inRange.length,
    dailyFlows: _buildDailyFlows(inRange, start, end),
    monthlyFlows: _buildMonthlyFlows(allTransactions, reference),
    recentTransactions: recent.take(5).toList(growable: false),
  );
}

/// Giới hạn số cột tối đa của biểu đồ theo ngày, để một khoảng "Tùy chọn" rất
/// dài (nhiều năm) không làm vỡ layout — chỉ lấy [_maxDailyBuckets] ngày gần
/// [end] nhất.
const _maxDailyBuckets = 62;

List<DailyFlow> _buildDailyFlows(List<Transaction> inRange, DateTime start, DateTime end) {
  final totalDays = end.difference(start).inDays;
  if (totalDays <= 0) return const [];

  final days = totalDays > _maxDailyBuckets ? _maxDailyBuckets : totalDays;
  final effectiveStart = totalDays > _maxDailyBuckets ? end.subtract(Duration(days: days)) : start;

  final incomeByDay = <DateTime, int>{};
  final expenseByDay = <DateTime, int>{};
  for (var i = 0; i < days; i++) {
    final day = effectiveStart.add(Duration(days: i));
    incomeByDay[day] = 0;
    expenseByDay[day] = 0;
  }

  for (final t in inRange) {
    final day = DateTime(t.transactionTime.year, t.transactionTime.month, t.transactionTime.day);
    if (!incomeByDay.containsKey(day)) continue;
    if (t.type == TransactionType.income) {
      incomeByDay[day] = incomeByDay[day]! + t.amount;
    } else {
      expenseByDay[day] = expenseByDay[day]! + t.amount;
    }
  }

  final sortedDays = incomeByDay.keys.toList()..sort();
  return sortedDays
      .map((day) => DailyFlow(date: day, income: incomeByDay[day]!, expense: expenseByDay[day]!))
      .toList(growable: false);
}

/// Biểu đồ theo tháng luôn hiển thị 6 tháng gần nhất tính theo [reference],
/// không phụ thuộc bộ lọc Dashboard đang chọn — để luôn thấy được xu hướng
/// dài hạn dù đang lọc "Hôm nay" hay "7 ngày".
const _monthsToShow = 6;

List<MonthlyFlow> _buildMonthlyFlows(List<Transaction> all, DateTime reference) {
  final firstMonth = DateTime(reference.year, reference.month - (_monthsToShow - 1), 1);

  final incomeByMonth = <DateTime, int>{};
  final expenseByMonth = <DateTime, int>{};
  for (var i = 0; i < _monthsToShow; i++) {
    final month = DateTime(firstMonth.year, firstMonth.month + i, 1);
    incomeByMonth[month] = 0;
    expenseByMonth[month] = 0;
  }

  for (final t in all) {
    final month = DateTime(t.transactionTime.year, t.transactionTime.month, 1);
    if (!incomeByMonth.containsKey(month)) continue;
    if (t.type == TransactionType.income) {
      incomeByMonth[month] = incomeByMonth[month]! + t.amount;
    } else {
      expenseByMonth[month] = expenseByMonth[month]! + t.amount;
    }
  }

  final sortedMonths = incomeByMonth.keys.toList()..sort();
  return sortedMonths
      .map((month) => MonthlyFlow(month: month, income: incomeByMonth[month]!, expense: expenseByMonth[month]!))
      .toList(growable: false);
}
