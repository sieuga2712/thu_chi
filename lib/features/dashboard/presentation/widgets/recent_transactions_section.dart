import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../providers/nav_provider.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../../models/dashboard_summary.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Giao dịch gần đây',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 22,
              ),
            ),
            TextButton(
              onPressed: () => ref.read(navIndexProvider.notifier).set(1),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        if (summary.recentTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Chưa có giao dịch nào.\nHãy cấp quyền đọc thông báo ở mục Cài đặt.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black45,
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 17,
                ),
              ),
            ),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final t in summary.recentTransactions)
                  TransactionTile(transaction: t),
              ],
            ),
          ),
      ],
    );
  }
}
