import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_query.dart';

class TransactionQueryNotifier extends Notifier<TransactionQuery> {
  @override
  TransactionQuery build() => const TransactionQuery();

  void setSearchText(String value) => state = state.copyWith(searchText: value);

  void setTypeFilter(TransactionTypeFilter filter) =>
      state = state.copyWith(typeFilter: filter);
}

final transactionQueryProvider =
    NotifierProvider<TransactionQueryNotifier, TransactionQuery>(
      TransactionQueryNotifier.new,
    );
