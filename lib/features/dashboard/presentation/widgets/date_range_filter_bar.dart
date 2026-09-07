import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/date_range_filter.dart';
import '../../providers/dashboard_filter_provider.dart';

/// Dãy chip lọc thời gian: Hôm nay | 7 ngày | Tháng này | Tháng trước | Tùy chọn.
class DateRangeFilterBar extends ConsumerWidget {
  const DateRangeFilterBar({super.key});

  static const _options = [
    DateRangeType.today,
    DateRangeType.last7Days,
    DateRangeType.thisMonth,
    DateRangeType.lastMonth,
    DateRangeType.custom,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dashboardFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _options[index];
          final selected = filter.type == type;

          return ChoiceChip(
            label: Text(DateRangeFilter(type: type).label),
            selected: selected,
            onSelected: (_) => _onSelected(context, ref, type),
          );
        },
      ),
    );
  }

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    DateRangeType type,
  ) async {
    if (type != DateRangeType.custom) {
      ref.read(dashboardFilterProvider.notifier).setType(type);
      return;
    }

    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );

    if (range != null) {
      ref
          .read(dashboardFilterProvider.notifier)
          .setCustomRange(range.start, range.end);
    }
  }
}
