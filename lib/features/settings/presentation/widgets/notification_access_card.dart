import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../providers/notification_providers.dart';
import '../../../notification_access/providers/notification_access_provider.dart';

/// Thẻ trạng thái quyền "Notification access" (section 10, 11 của spec).
/// Tự làm mới khi app quay lại foreground, vì người dùng có thể vừa cấp
/// quyền ở màn hình Settings hệ thống rồi bấm nút Back trở lại app.
class NotificationAccessCard extends ConsumerStatefulWidget {
  const NotificationAccessCard({super.key});

  @override
  ConsumerState<NotificationAccessCard> createState() =>
      _NotificationAccessCardState();
}

class _NotificationAccessCardState extends ConsumerState<NotificationAccessCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationAccessGrantedProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grantedAsync = ref.watch(notificationAccessGrantedProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: grantedAsync.when(
          data: (granted) =>
              granted ? _buildGranted(context) : _buildNotGranted(context),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text('Không kiểm tra được quyền: $error'),
        ),
      ),
    );
  }

  Widget _buildGranted(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.income),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Đang theo dõi thông báo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.income,
              fontWeight: FontWeight.bold,
              fontFamily: RetroStyle.fontFamily,
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotGranted(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.expense),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Chưa cấp quyền đọc thông báo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.expense,
                  fontWeight: FontWeight.bold,
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'App cần quyền này để đọc thông báo biến động số dư từ VietinBank iPay. '
          'App không đăng nhập, không lưu mật khẩu ngân hàng.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () async {
            final service = ref.read(nativeNotificationServiceProvider);
            await service.openNotificationAccessSettings();
          },
          child: const Text('Cấp quyền'),
        ),
      ],
    );
  }
}
