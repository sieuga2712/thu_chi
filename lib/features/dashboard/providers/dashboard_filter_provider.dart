import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_range_filter.dart';

class DashboardFilterNotifier extends Notifier<DateRangeFilter> {
  @override
  DateRangeFilter build() => DateRangeFilter.initial;

  void setType(DateRangeType type) {
    state = DateRangeFilter(type: type);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = DateRangeFilter(
      type: DateRangeType.custom,
      customStart: start,
      customEnd: end,
    );
  }
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, DateRangeFilter>(
      DashboardFilterNotifier.new,
    );
