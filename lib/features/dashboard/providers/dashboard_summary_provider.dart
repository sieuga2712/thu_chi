import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/database_providers.dart';
import '../logic/dashboard_summary_calculator.dart';
import '../models/dashboard_summary.dart';
import 'dashboard_filter_provider.dart';

/// Tự tính lại mỗi khi bộ lọc thời gian đổi. Chưa tự refresh khi có giao
/// dịch mới được insert "ngầm" (sẽ nối vào pipeline notification ở Phase 8);
/// hiện tại UI dùng RefreshIndicator (kéo để làm mới) để chủ động invalidate.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(dashboardFilterProvider);

  final all = await repository.getTransactions();
  return computeDashboardSummary(all, filter);
});
