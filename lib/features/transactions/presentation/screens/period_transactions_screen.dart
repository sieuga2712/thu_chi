import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/retro_style.dart';
import '../../providers/transaction_list_provider.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';

/// Toàn bộ giao dịch trong 1 khoảng thời gian ([start] inclusive, [end]
/// exclusive) — mở từ màn hình Giao dịch (bấm vào 1 dòng ngày/tuần/tháng).
/// Theo dõi trực tiếp [filteredTransactionsProvider] (không nhận sẵn danh
/// sách tĩnh) để tự cập nhật ngay khi xóa/sửa giao dịch bên trong, kể cả
/// sau khi quay lại từ [TransactionDetailScreen].
class PeriodTransactionsScreen extends ConsumerWidget {
  const PeriodTransactionsScreen({
    super.key,
    required this.title,
    required this.start,
    required this.end,
  });

  final String title;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: filteredAsync.when(
        data: (all) {
          final transactions = all
              .where(
                (t) =>
                    !t.transactionTime.isBefore(start) &&
                    t.transactionTime.isBefore(end),
              )
              .toList();

          if (transactions.isEmpty) {
            return const Center(
              child: Text('Không còn giao dịch nào trong khoảng này'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Container(
                decoration: RetroStyle.panelBorderOnly,
                child: Material(
                  color: RetroStyle.panelFill,
                  child: TransactionTile(
                    transaction: transaction,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionDetailScreen(transaction: transaction),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}
