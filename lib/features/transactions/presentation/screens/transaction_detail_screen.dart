import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/transaction.dart';
import '../../../../models/transaction_type.dart';
import '../../../../providers/database_providers.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../providers/transaction_list_provider.dart';

/// Chi tiết một giao dịch (section 9). Có tùy chọn xóa giao dịch.
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa giao dịch',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(
              CurrencyFormatter.formatSigned(
                transaction.amount,
                isIncome: isIncome,
                currency: transaction.currency,
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(label: 'Loại', value: isIncome ? 'Tiền vào' : 'Tiền ra'),
                  _DetailRow(
                    label: 'Thời gian',
                    value: AppDateFormatter.formatDateTime(transaction.transactionTime),
                  ),
                  _DetailRow(label: 'Tài khoản', value: transaction.account ?? '—'),
                  _DetailRow(
                    label: 'Số dư sau giao dịch',
                    value: transaction.balanceAfter != null
                        ? CurrencyFormatter.format(
                            transaction.balanceAfter!,
                            currency: transaction.currency,
                          )
                        : '—',
                  ),
                  if (transaction.transactionCode != null)
                    _DetailRow(label: 'Mã giao dịch', value: transaction.transactionCode!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nội dung',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                transaction.description.isEmpty ? '(Không có nội dung)' : transaction.description,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Giao dịch này sẽ bị xóa khỏi lịch sử. Hành động không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirmed != true || transaction.id == null) return;

    final repository = ref.read(transactionRepositoryProvider);
    await repository.delete(transaction.id!);
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardSummaryProvider);

    if (context.mounted) Navigator.of(context).pop();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
