import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_filter_provider.dart';
import '../../providers/dashboard_summary_provider.dart';
import '../widgets/achievement_highlight_card.dart';
import '../widgets/activity_today_card.dart';
import '../widgets/date_range_filter_bar.dart';
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
              const SizedBox(height: 16),
              const ActivityTodayCard(),
              const SizedBox(height: 12),
              const AchievementHighlightCard(),
              // Giao dịch gần đây: tạm ẩn theo yêu cầu, xem RecentTransactionsSection.
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Không thể tải dữ liệu: $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
