import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_list_provider.dart';
import '../widgets/transaction_search_bar.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transaction_type_filter_bar.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allTransactionsProvider),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TransactionSearchBar(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TransactionTypeFilterBar(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Không tìm thấy giao dịch nào')),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final transaction = list[index];
                      return TransactionTile(
                        transaction: transaction,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TransactionDetailScreen(transaction: transaction),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Lỗi: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
