import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/dashboard_summary.dart';
import '../../models/date_range_filter.dart';
import 'stat_card.dart';

/// Khối "TỔNG QUAN" — 4 ô thống kê Tiền vào / Tiền ra / Chênh lệch / Số giao
/// dịch, xem mockup ở section 7 của spec.
class SummaryOverviewCard extends StatelessWidget {
  const SummaryOverviewCard({super.key, required this.summary, required this.filter});

  final DashboardSummary summary;
  final DateRangeFilter filter;

  @override
  Widget build(BuildContext context) {
    final isNetPositive = summary.net >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TỔNG QUAN',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(filter.label),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            StatCard(
              label: 'Tiền vào',
              value: CurrencyFormatter.format(summary.totalIncome),
              icon: Icons.arrow_upward,
              color: AppColors.income,
            ),
            StatCard(
              label: 'Tiền ra',
              value: CurrencyFormatter.format(summary.totalExpense),
              icon: Icons.arrow_downward,
              color: AppColors.expense,
            ),
            StatCard(
              label: 'Chênh lệch',
              value: CurrencyFormatter.formatSigned(summary.net.abs(), isIncome: isNetPositive),
              icon: isNetPositive ? Icons.trending_up : Icons.trending_down,
              color: isNetPositive ? AppColors.income : AppColors.expense,
            ),
            StatCard(
              label: 'Số giao dịch',
              value: '${summary.transactionCount}',
              icon: Icons.receipt_long,
              color: AppColors.neutral,
            ),
          ],
        ),
      ],
    );
  }
}
