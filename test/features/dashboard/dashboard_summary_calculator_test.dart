import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/dashboard/logic/dashboard_summary_calculator.dart';
import 'package:thu_chi/features/dashboard/models/date_range_filter.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';

void main() {
  Transaction tx({
    required TransactionType type,
    required int amount,
    required DateTime time,
  }) {
    return Transaction(
      type: type,
      amount: amount,
      currency: 'VND',
      description: 'test',
      transactionTime: time,
      rawNotification: 'raw',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  final now = DateTime(2026, 8, 10, 15, 0);

  test('tính đúng tổng thu/chi/net/số giao dịch trong khoảng lọc', () {
    final transactions = [
      tx(type: TransactionType.income, amount: 2000000, time: DateTime(2026, 8, 10, 8)),
      tx(type: TransactionType.expense, amount: 350000, time: DateTime(2026, 8, 10, 12)),
      // Ngoài "tháng này" -> không được tính.
      tx(type: TransactionType.income, amount: 5000000, time: DateTime(2026, 7, 1)),
    ];

    final summary = computeDashboardSummary(
      transactions,
      const DateRangeFilter(type: DateRangeType.thisMonth),
      now: now,
    );

    expect(summary.totalIncome, 2000000);
    expect(summary.totalExpense, 350000);
    expect(summary.net, 1650000);
    expect(summary.transactionCount, 2);
  });

  test('bộ lọc "Hôm nay" chỉ tính giao dịch trong ngày hiện tại', () {
    final transactions = [
      tx(type: TransactionType.income, amount: 100000, time: DateTime(2026, 8, 10, 0, 1)),
      tx(type: TransactionType.income, amount: 999999, time: DateTime(2026, 8, 9, 23, 59)),
    ];

    final summary = computeDashboardSummary(
      transactions,
      const DateRangeFilter(type: DateRangeType.today),
      now: now,
    );

    expect(summary.totalIncome, 100000);
    expect(summary.transactionCount, 1);
  });

  test('không có giao dịch nào -> summary rỗng, không crash', () {
    final summary = computeDashboardSummary(
      const [],
      const DateRangeFilter(type: DateRangeType.thisMonth),
      now: now,
    );

    expect(summary.totalIncome, 0);
    expect(summary.totalExpense, 0);
    expect(summary.transactionCount, 0);
    expect(summary.recentTransactions, isEmpty);
  });

  test('dailyFlows có đủ số cột theo đúng số ngày trong khoảng lọc, gộp đúng theo ngày', () {
    final transactions = [
      tx(type: TransactionType.income, amount: 1000, time: DateTime(2026, 8, 1, 9)),
      tx(type: TransactionType.income, amount: 2000, time: DateTime(2026, 8, 1, 20)),
      tx(type: TransactionType.expense, amount: 500, time: DateTime(2026, 8, 2, 9)),
    ];

    final summary = computeDashboardSummary(
      transactions,
      const DateRangeFilter(type: DateRangeType.thisMonth),
      now: now,
    );

    // Tháng 8/2026 có 31 ngày.
    expect(summary.dailyFlows, hasLength(31));
    expect(summary.dailyFlows[0].date, DateTime(2026, 8, 1));
    expect(summary.dailyFlows[0].income, 3000);
    expect(summary.dailyFlows[1].expense, 500);
    expect(summary.dailyFlows[2].income, 0);
    expect(summary.dailyFlows[2].expense, 0);
  });

  test('monthlyFlows luôn có 6 tháng gần nhất, không phụ thuộc bộ lọc đang chọn', () {
    final transactions = [
      tx(type: TransactionType.income, amount: 1000000, time: DateTime(2026, 8, 5)),
      tx(type: TransactionType.expense, amount: 200000, time: DateTime(2026, 6, 5)),
      // Quá cũ, ngoài 6 tháng gần nhất tính từ 2026-08 -> không được tính.
      tx(type: TransactionType.income, amount: 999999, time: DateTime(2025, 1, 1)),
    ];

    final summary = computeDashboardSummary(
      transactions,
      const DateRangeFilter(type: DateRangeType.today), // filter khác không ảnh hưởng monthlyFlows
      now: now,
    );

    expect(summary.monthlyFlows, hasLength(6));
    expect(summary.monthlyFlows.first.month, DateTime(2026, 3, 1));
    expect(summary.monthlyFlows.last.month, DateTime(2026, 8, 1));
    expect(summary.monthlyFlows.last.income, 1000000);
    final juneFlow = summary.monthlyFlows.firstWhere((m) => m.month == DateTime(2026, 6, 1));
    expect(juneFlow.expense, 200000);
  });

  test('recentTransactions lấy tối đa 5 giao dịch mới nhất theo thời gian, không phụ thuộc bộ lọc', () {
    final transactions = List.generate(
      8,
      (i) => tx(
        type: TransactionType.income,
        amount: i,
        time: DateTime(2026, 1, i + 1),
      ),
    );

    final summary = computeDashboardSummary(
      transactions,
      const DateRangeFilter(type: DateRangeType.today),
      now: now,
    );

    expect(summary.recentTransactions, hasLength(5));
    expect(summary.recentTransactions.first.transactionTime, DateTime(2026, 1, 8));
    expect(summary.recentTransactions.last.transactionTime, DateTime(2026, 1, 4));
  });
}
