import 'package:equatable/equatable.dart';

import '../../../models/transaction.dart';

/// Tổng thu/chi của một ngày — một cột trong biểu đồ "tiền vào/tiền ra theo ngày".
class DailyFlow extends Equatable {
  const DailyFlow({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final int income;
  final int expense;

  @override
  List<Object?> get props => [date, income, expense];
}

/// Tổng thu/chi của một tháng — một cột trong biểu đồ "thu/chi theo tháng".
class MonthlyFlow extends Equatable {
  const MonthlyFlow({
    required this.month,
    required this.income,
    required this.expense,
  });

  /// Luôn là ngày 1 của tháng đó.
  final DateTime month;
  final int income;
  final int expense;

  @override
  List<Object?> get props => [month, income, expense];
}

/// Toàn bộ dữ liệu Dashboard cần để vẽ, đã tính sẵn theo bộ lọc đang chọn.
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
    required this.dailyFlows,
    required this.monthlyFlows,
    required this.recentTransactions,
  });

  const DashboardSummary.empty()
    : totalIncome = 0,
      totalExpense = 0,
      transactionCount = 0,
      dailyFlows = const [],
      monthlyFlows = const [],
      recentTransactions = const [];

  final int totalIncome;
  final int totalExpense;
  final int transactionCount;
  final List<DailyFlow> dailyFlows;
  final List<MonthlyFlow> monthlyFlows;
  final List<Transaction> recentTransactions;

  int get net => totalIncome - totalExpense;

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    transactionCount,
    dailyFlows,
    monthlyFlows,
    recentTransactions,
  ];
}
