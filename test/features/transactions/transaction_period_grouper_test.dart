import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/transactions/logic/transaction_period_grouper.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';

void main() {
  Transaction tx({
    required TransactionType type,
    required int amount,
    required DateTime time,
    String description = 'test',
  }) {
    return Transaction(
      type: type,
      amount: amount,
      currency: 'VND',
      description: description,
      transactionTime: time,
      rawNotification: 'raw',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  group('groupTransactionsByDay', () {
    test('danh sách rỗng trả về danh sách nhóm rỗng', () {
      expect(groupTransactionsByDay([]), isEmpty);
    });

    test('gom đúng theo ngày (bỏ giờ/phút/giây), tổng tiền vào/ra riêng biệt', () {
      final groups = groupTransactionsByDay([
        tx(
          type: TransactionType.income,
          amount: 2000000,
          time: DateTime(2026, 8, 10, 8, 30),
        ),
        tx(
          type: TransactionType.expense,
          amount: 350000,
          time: DateTime(2026, 8, 10, 20, 0),
        ),
        tx(
          type: TransactionType.expense,
          amount: 100000,
          time: DateTime(2026, 8, 9, 9, 0),
        ),
      ]);

      expect(groups, hasLength(2));
      // Ngày mới nhất trước.
      expect(groups[0].start, DateTime(2026, 8, 10));
      expect(groups[0].end, DateTime(2026, 8, 11));
      expect(groups[0].transactions, hasLength(2));
      expect(groups[0].totalIncome, 2000000);
      expect(groups[0].totalExpense, 350000);
      // Trong ngày, giao dịch mới nhất trước.
      expect(groups[0].transactions.first.amount, 350000);

      expect(groups[1].start, DateTime(2026, 8, 9));
      expect(groups[1].totalIncome, 0);
      expect(groups[1].totalExpense, 100000);
    });
  });

  group('groupTransactionsByWeek', () {
    test('gom đúng theo tuần (bắt đầu Thứ 2), tuần mới nhất trước', () {
      // 2026-08-10 là Thứ 2, 2026-08-16 là Chủ nhật cùng tuần.
      // 2026-08-03 là Thứ 2 tuần trước.
      final groups = groupTransactionsByWeek([
        tx(
          type: TransactionType.income,
          amount: 1000000,
          time: DateTime(2026, 8, 10, 8, 0),
        ),
        tx(
          type: TransactionType.expense,
          amount: 200000,
          time: DateTime(2026, 8, 16, 20, 0),
        ),
        tx(
          type: TransactionType.expense,
          amount: 50000,
          time: DateTime(2026, 8, 3, 9, 0),
        ),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0].start, DateTime(2026, 8, 10));
      expect(groups[0].end, DateTime(2026, 8, 17));
      expect(groups[0].transactions, hasLength(2));
      expect(groups[0].totalIncome, 1000000);
      expect(groups[0].totalExpense, 200000);

      expect(groups[1].start, DateTime(2026, 8, 3));
      expect(groups[1].totalExpense, 50000);
    });
  });

  group('groupTransactionsByMonth', () {
    test('gom đúng theo tháng, tháng mới nhất trước', () {
      final groups = groupTransactionsByMonth([
        tx(
          type: TransactionType.income,
          amount: 5000000,
          time: DateTime(2026, 8, 1, 8, 0),
        ),
        tx(
          type: TransactionType.expense,
          amount: 300000,
          time: DateTime(2026, 8, 31, 20, 0),
        ),
        tx(
          type: TransactionType.expense,
          amount: 150000,
          time: DateTime(2026, 7, 15, 9, 0),
        ),
      ]);

      expect(groups, hasLength(2));
      expect(groups[0].start, DateTime(2026, 8, 1));
      expect(groups[0].end, DateTime(2026, 9, 1));
      expect(groups[0].totalIncome, 5000000);
      expect(groups[0].totalExpense, 300000);

      expect(groups[1].start, DateTime(2026, 7, 1));
      expect(groups[1].end, DateTime(2026, 8, 1));
      expect(groups[1].totalExpense, 150000);
    });
  });
}
