import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/transaction.dart';
import '../../../../models/transaction_type.dart';

/// Một dòng giao dịch, dùng chung giữa Dashboard (mục "Giao dịch gần đây")
/// và màn hình danh sách giao dịch (Phase 7).
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: RetroIconBadge(
        icon: isIncome ? Icons.arrow_upward : Icons.arrow_downward,
        color: color,
        size: 40,
        iconSize: 20,
      ),
      title: Text(
        CurrencyFormatter.formatSigned(
          transaction.amount,
          isIncome: isIncome,
          currency: transaction.currency,
        ),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontFamily: RetroStyle.fontFamily,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.description.isEmpty
                ? '(Không có nội dung)'
                : transaction.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: RetroStyle.fontFamily,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                AppDateFormatter.formatDateTime(transaction.transactionTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 15,
                ),
              ),
              if (transaction.category.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '•',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: RetroStyle.fontFamily,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    transaction.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: RetroStyle.fontFamily,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: transaction.balanceAfter == null
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Số dư',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: RetroStyle.fontFamily,
                    fontSize: 15,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    transaction.balanceAfter!,
                    currency: transaction.currency,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: RetroStyle.fontFamily,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
      isThreeLine: true,
    );
  }
}
