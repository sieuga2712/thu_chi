import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction_query.dart';
import '../../providers/transaction_query_provider.dart';

/// Dãy chip lọc: Tất cả | Tiền vào | Tiền ra (section 8).
class TransactionTypeFilterBar extends ConsumerWidget {
  const TransactionTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(transactionQueryProvider);
    final notifier = ref.read(transactionQueryProvider.notifier);

    return Row(
      children: [
        ChoiceChip(
          label: const Text('Tất cả'),
          selected: query.typeFilter == TransactionTypeFilter.all,
          onSelected: (_) => notifier.setTypeFilter(TransactionTypeFilter.all),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Tiền vào'),
          selected: query.typeFilter == TransactionTypeFilter.income,
          onSelected: (_) => notifier.setTypeFilter(TransactionTypeFilter.income),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Tiền ra'),
          selected: query.typeFilter == TransactionTypeFilter.expense,
          onSelected: (_) => notifier.setTypeFilter(TransactionTypeFilter.expense),
        ),
      ],
    );
  }
}
