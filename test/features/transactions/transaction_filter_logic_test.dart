import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/features/transactions/logic/transaction_filter_logic.dart';
import 'package:thu_chi/features/transactions/models/transaction_query.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';

void main() {
  Transaction tx({
    required TransactionType type,
    required int amount,
    String description = '',
    String? account,
    DateTime? time,
  }) {
    return Transaction(
      type: type,
      amount: amount,
      currency: 'VND',
      account: account,
      description: description,
      transactionTime: time ?? DateTime(2026, 8, 10),
      rawNotification: 'raw',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  final income = tx(
    type: TransactionType.income,
    amount: 2000000,
    description: 'NGUYEN VAN A CHUYEN TIEN',
    account: '****1234',
    time: DateTime(2026, 8, 10, 8, 30),
  );
  final expense = tx(
    type: TransactionType.expense,
    amount: 350000,
    description: 'THANH TOAN CAFE',
    account: '****5678',
    time: DateTime(2026, 8, 9, 12, 0),
  );
  final all = [income, expense];

  test('typeFilter = all trả về mọi giao dịch, sắp xếp mới nhất trước', () {
    final result = filterTransactions(all, const TransactionQuery());

    expect(result, hasLength(2));
    expect(result.first, income);
  });

  test('typeFilter = income chỉ trả về giao dịch tiền vào', () {
    final result = filterTransactions(
      all,
      const TransactionQuery(typeFilter: TransactionTypeFilter.income),
    );

    expect(result, [income]);
  });

  test('typeFilter = expense chỉ trả về giao dịch tiền ra', () {
    final result = filterTransactions(
      all,
      const TransactionQuery(typeFilter: TransactionTypeFilter.expense),
    );

    expect(result, [expense]);
  });

  test('tìm theo nội dung, không phân biệt hoa/thường', () {
    final result = filterTransactions(all, const TransactionQuery(searchText: 'cafe'));

    expect(result, [expense]);
  });

  test('tìm theo số tài khoản', () {
    final result = filterTransactions(all, const TransactionQuery(searchText: '1234'));

    expect(result, [income]);
  });

  test('tìm theo số tiền có định dạng dấu phẩy vẫn khớp', () {
    final result = filterTransactions(all, const TransactionQuery(searchText: '2,000,000'));

    expect(result, [income]);
  });

  test('tìm theo số tiền không định dạng cũng khớp', () {
    final result = filterTransactions(all, const TransactionQuery(searchText: '350000'));

    expect(result, [expense]);
  });

  test('kết hợp tìm kiếm + lọc loại giao dịch', () {
    final result = filterTransactions(
      all,
      const TransactionQuery(searchText: 'cafe', typeFilter: TransactionTypeFilter.income),
    );

    expect(result, isEmpty);
  });

  test('không khớp gì trả về danh sách rỗng, không crash', () {
    final result = filterTransactions(all, const TransactionQuery(searchText: 'khong ton tai'));

    expect(result, isEmpty);
  });
}
