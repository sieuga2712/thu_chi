import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../logic/transaction_period_grouper.dart';

/// Một dòng tổng hợp giao dịch trong 1 khoảng thời gian (ngày/tuần/tháng),
/// dùng chung cho cả 3 chế độ xem ở màn hình Giao dịch — bấm vào mở
/// [PeriodTransactionsScreen] xem chi tiết.
class PeriodSummaryTile extends StatelessWidget {
  const PeriodSummaryTile({
    super.key,
    required this.label,
    required this.group,
    this.onTap,
  });

  final String label;
  final PeriodTransactionGroup group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const RetroIconBadge(
        icon: Icons.calendar_today,
        color: RetroStyle.borderDark,
        size: 40,
        iconSize: 18,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: RetroStyle.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${group.transactions.length} giao dịch',
        style: const TextStyle(fontFamily: RetroStyle.fontFamily, fontSize: 15),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (group.totalIncome > 0)
            Text(
              CurrencyFormatter.formatSigned(
                group.totalIncome,
                isIncome: true,
              ),
              style: const TextStyle(
                color: AppColors.income,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (group.totalExpense > 0)
            Text(
              CurrencyFormatter.formatSigned(
                group.totalExpense,
                isIncome: false,
              ),
              style: const TextStyle(
                color: AppColors.expense,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
