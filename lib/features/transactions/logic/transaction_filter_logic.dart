import '../../../models/transaction.dart';
import '../../../models/transaction_type.dart';
import '../models/transaction_query.dart';

/// Lọc + tìm kiếm danh sách giao dịch. Hàm thuần (pure function) để dễ unit
/// test độc lập với Riverpod/DB.
///
/// Tìm theo nội dung, tài khoản (không phân biệt hoa/thường), và số tiền —
/// số tiền được so khớp sau khi bỏ hết dấu phẩy/chấm ở cả hai phía, để tìm
/// "2,000,000" hay "2000000" đều ra cùng kết quả.
List<Transaction> filterTransactions(List<Transaction> all, TransactionQuery query) {
  Iterable<Transaction> result = all;

  switch (query.typeFilter) {
    case TransactionTypeFilter.all:
      break;
    case TransactionTypeFilter.income:
      result = result.where((t) => t.type == TransactionType.income);
    case TransactionTypeFilter.expense:
      result = result.where((t) => t.type == TransactionType.expense);
  }

  final search = query.searchText.trim().toLowerCase();
  if (search.isNotEmpty) {
    final numericSearch = search.replaceAll(RegExp(r'[^\d]'), '');

    result = result.where((t) {
      final inDescription = t.description.toLowerCase().contains(search);
      final inAccount = (t.account ?? '').toLowerCase().contains(search);
      final inAmount = numericSearch.isNotEmpty && t.amount.toString().contains(numericSearch);
      return inDescription || inAccount || inAmount;
    });
  }

  return result.toList()..sort((a, b) => b.transactionTime.compareTo(a.transactionTime));
}
