import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_filter_provider.dart';
import '../../providers/dashboard_summary_provider.dart';
import '../widgets/daily_flow_chart.dart';
import '../widgets/date_range_filter_bar.dart';
import '../widgets/monthly_flow_chart.dart';
import '../widgets/recent_transactions_section.dart';
import '../widgets/summary_overview_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final filter = ref.watch(dashboardFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
        child: summaryAsync.when(
          data: (summary) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const DateRangeFilterBar(),
              const SizedBox(height: 16),
              SummaryOverviewCard(summary: summary, filter: filter),
              const SizedBox(height: 24),
              Text(
                'Tiền vào / tiền ra theo ngày',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DailyFlowChart(flows: summary.dailyFlows),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Thu / chi theo tháng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: MonthlyFlowChart(flows: summary.monthlyFlows),
                ),
              ),
              const SizedBox(height: 24),
              RecentTransactionsSection(summary: summary),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Không thể tải dữ liệu: $error', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
