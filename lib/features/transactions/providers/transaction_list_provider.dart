import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/transaction.dart';
import '../../../providers/database_providers.dart';
import '../logic/transaction_filter_logic.dart';
import 'transaction_query_provider.dart';

/// Toàn bộ giao dịch trong DB, chưa lọc. Gọi `ref.invalidate(allTransactionsProvider)`
/// sau khi insert/xóa để làm mới danh sách.
final allTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactions();
});

/// Danh sách đã áp dụng tìm kiếm + bộ lọc loại giao dịch đang chọn.
final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final query = ref.watch(transactionQueryProvider);
  final allAsync = ref.watch(allTransactionsProvider);
  return allAsync.whenData((all) => filterTransactions(all, query));
});
