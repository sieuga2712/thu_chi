import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/budget/logic/budget_progress_calculator.dart';
import 'package:thu_chi/models/budget_config.dart';
import 'package:thu_chi/models/budget_period.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';

void main() {
  // Thứ Năm 13/08/2026 — tuần chứa ngày này là Thứ 2 10/08 -> Chủ nhật 16/08.
  final now = DateTime(2026, 8, 13, 10, 0);

  Transaction expense(int amount, DateTime time) {
    return Transaction(
      type: TransactionType.expense,
      amount: amount,
      currency: 'VND',
      description: 'test',
      transactionTime: time,
      rawNotification: 'raw',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  Transaction income(int amount, DateTime time) {
    return Transaction(
      type: TransactionType.income,
      amount: amount,
      currency: 'VND',
      description: 'test',
      transactionTime: time,
      rawNotification: 'raw',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  test('chỉ cộng giao dịch chi tiêu (expense), bỏ qua tiền vào', () {
    final all = [expense(100000, now), income(500000, now)];

    final spent = computeSpentInCurrentPeriod(
      all,
      const BudgetConfig(period: BudgetPeriod.week, limitAmount: 1000000),
      now: now,
    );

    expect(spent, 100000);
  });

  test('kỳ tuần: chỉ tính giao dịch từ Thứ 2 tuần này trở đi, bỏ qua tuần trước', () {
    final all = [
      expense(50000, DateTime(2026, 8, 9, 23, 59)), // Chủ nhật tuần trước
      expense(70000, DateTime(2026, 8, 10, 0, 0)), // Thứ 2 tuần này (đầu kỳ)
      expense(30000, DateTime(2026, 8, 16, 23, 59)), // Chủ nhật tuần này (cuối kỳ)
      expense(20000, DateTime(2026, 8, 17, 0, 0)), // Thứ 2 tuần sau (ngoài kỳ)
    ];

    final spent = computeSpentInCurrentPeriod(
      all,
      const BudgetConfig(period: BudgetPeriod.week, limitAmount: 1000000),
      now: now,
    );

    expect(spent, 100000); // 70000 + 30000
  });

  test('kỳ tháng: chỉ tính giao dịch trong tháng hiện tại', () {
    final all = [
      expense(50000, DateTime(2026, 7, 31, 23, 59)), // tháng trước
      expense(60000, DateTime(2026, 8, 1, 0, 0)), // đầu tháng này
      expense(40000, DateTime(2026, 8, 31, 23, 59)), // cuối tháng này
      expense(10000, DateTime(2026, 9, 1, 0, 0)), // tháng sau
    ];

    final spent = computeSpentInCurrentPeriod(
      all,
      const BudgetConfig(period: BudgetPeriod.month, limitAmount: 1000000),
      now: now,
    );

    expect(spent, 100000); // 60000 + 40000
  });

  test('không có giao dịch nào trong kỳ thì trả về 0', () {
    final spent = computeSpentInCurrentPeriod(
      const [],
      const BudgetConfig(period: BudgetPeriod.week, limitAmount: 1000000),
      now: now,
    );

    expect(spent, 0);
  });
}
