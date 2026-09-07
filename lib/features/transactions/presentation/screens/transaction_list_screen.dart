import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../activity/logic/iso_week.dart';
import '../../logic/transaction_period_grouper.dart';
import '../../providers/transaction_list_provider.dart';
import '../widgets/period_summary_tile.dart';
import '../widgets/transaction_search_bar.dart';
import '../widgets/transaction_type_filter_bar.dart';
import 'manual_transaction_entry_screen.dart';
import 'period_transactions_screen.dart';

enum _ViewMode { day, week, month }

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends ConsumerState<TransactionListScreen> {
  _ViewMode _viewMode = _ViewMode.day;

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GIAO DỊCH'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm giao dịch thủ công',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ManualTransactionEntryScreen(),
              ),
            ),
          ),
        ],
      ),
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
            Center(
              child: SegmentedButton<_ViewMode>(
                segments: const [
                  ButtonSegment(value: _ViewMode.day, label: Text('Ngày')),
                  ButtonSegment(value: _ViewMode.week, label: Text('Tuần')),
                  ButtonSegment(value: _ViewMode.month, label: Text('Tháng')),
                ],
                selected: {_viewMode},
                onSelectionChanged: (s) => setState(() => _viewMode = s.first),
              ),
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

                  final groups = switch (_viewMode) {
                    _ViewMode.day => groupTransactionsByDay(list),
                    _ViewMode.week => groupTransactionsByWeek(list),
                    _ViewMode.month => groupTransactionsByMonth(list),
                  };

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: groups.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final label = _labelFor(_viewMode, group.start);
                      return Container(
                        decoration: RetroStyle.panelBorderOnly,
                        child: Material(
                          color: RetroStyle.panelFill,
                          child: PeriodSummaryTile(
                            label: label,
                            group: group,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PeriodTransactionsScreen(
                                  title: label,
                                  start: group.start,
                                  end: group.end,
                                ),
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
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(_ViewMode mode, DateTime periodStart) {
    switch (mode) {
      case _ViewMode.day:
        return AppDateFormatter.formatDate(periodStart);
      case _ViewMode.week:
        return 'Tuần ${isoWeekNumber(periodStart)} • ${isoWeekYear(periodStart)}';
      case _ViewMode.month:
        return AppDateFormatter.formatMonthLabel(periodStart);
    }
  }
}
