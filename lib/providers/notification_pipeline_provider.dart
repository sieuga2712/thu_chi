import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dashboard/providers/dashboard_summary_provider.dart';
import '../features/transactions/providers/transaction_list_provider.dart';
import '../services/notification_pipeline_service.dart';
import 'database_providers.dart';
import 'notification_providers.dart';

final notificationPipelineServiceProvider = Provider<NotificationPipelineService>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return NotificationPipelineService(repository: repository);
});

/// Khởi động toàn bộ pipeline notification -> parser -> DB:
/// 1) Rút hết backlog mà native đã đệm trong lúc app không chạy/không lắng
///    nghe (xem NotificationStore.kt).
/// 2) Lắng nghe stream sống trong suốt thời gian app mở, insert ngay khi có
///    notification mới và parse được.
///
/// Phải được `ref.watch` từ một widget luôn mounted (xem AppShell) để không
/// bị dispose giữa chừng — nếu không, StreamSubscription bên trong sẽ bị
/// hủy và app ngừng nhận giao dịch mới dù đang mở.
final notificationPipelineProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationPipelineServiceProvider);
  final nativeService = ref.watch(nativeNotificationServiceProvider);

  final pending = await nativeService.getPendingNotifications();
  if (pending.isNotEmpty) {
    await service.processAll(pending);
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardSummaryProvider);
  }

  final subscription = nativeService.notificationStream.listen((notification) async {
    final result = await service.process(notification);
    if (result != null) {
      ref.invalidate(allTransactionsProvider);
      ref.invalidate(dashboardSummaryProvider);
    }
  });

  ref.onDispose(subscription.cancel);
});
