import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/database_providers.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/supabase_providers.dart';
import '../../../../services/csv_transaction_codec.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../../transactions/providers/transaction_list_provider.dart';
import '../widgets/notification_access_card.dart';
import '../widgets/settings_action_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const NotificationAccessCard(),
          const SizedBox(height: 24),
          _SectionLabel('Kiểm tra'),
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                SettingsActionTile(
                  icon: Icons.science_outlined,
                  title: 'Gửi thông báo thử nghiệm',
                  subtitle: 'Kiểm tra parser mà không cần thông báo VietinBank thật',
                  onTap: () => _sendTestNotification(context, ref),
                ),
                const Divider(height: 1),
                SettingsActionTile(
                  icon: Icons.refresh,
                  title: 'Quét lại thông báo đang hiển thị',
                  subtitle:
                      'Bắt lại giao dịch có notification vẫn còn trong thanh thông báo '
                      '(ví dụ vừa cấp quyền hoặc vừa cấu hình package)',
                  onTap: () => _rescanActiveNotifications(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Ghi chú'),
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: SettingsActionTile(
              icon: Icons.cloud_sync_outlined,
              title: 'Đồng bộ ghi chú từ Supabase',
              subtitle:
                  'Kéo ghi chú vừa sửa trên máy tính (qua Supabase Table Editor) về máy này',
              onTap: () => _pullNotes(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Dữ liệu'),
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                SettingsActionTile(
                  icon: Icons.file_download_outlined,
                  title: 'Export dữ liệu CSV',
                  onTap: () => _exportCsv(context, ref),
                ),
                const Divider(height: 1),
                SettingsActionTile(
                  icon: Icons.file_upload_outlined,
                  title: 'Import dữ liệu CSV',
                  onTap: () => _importCsv(context, ref),
                ),
                const Divider(height: 1),
                SettingsActionTile(
                  icon: Icons.delete_forever_outlined,
                  iconColor: AppColors.expense,
                  title: 'Xóa toàn bộ dữ liệu',
                  onTap: () => _confirmDeleteAll(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Khác'),
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: SettingsActionTile(
              icon: Icons.info_outline,
              title: 'Giới thiệu ${AppConfig.appName}',
              onTap: () => _showAbout(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification(BuildContext context, WidgetRef ref) async {
    final service = ref.read(nativeNotificationServiceProvider);
    await service.sendTestNotification();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi thông báo thử nghiệm — kiểm tra tab Giao dịch')),
      );
    }
  }

  Future<void> _rescanActiveNotifications(BuildContext context, WidgetRef ref) async {
    final service = ref.read(nativeNotificationServiceProvider);
    final ok = await service.rescanActiveNotifications();

    if (!context.mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa cấp quyền đọc thông báo, không quét được')),
      );
      return;
    }

    // Đợi một nhịp để pipeline (EventChannel -> parser -> insert) kịp xử lý
    // trước khi làm mới danh sách, vì quét là bất đồng bộ ở phía native.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardSummaryProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã quét xong — kiểm tra tab Giao dịch')),
      );
    }
  }

  Future<void> _pullNotes(BuildContext context, WidgetRef ref) async {
    try {
      final appliedCount = await ref.read(noteSyncServiceProvider).pullAllNotes();
      ref.invalidate(allTransactionsProvider);

      if (context.mounted) {
        final message = appliedCount > 0
            ? 'Đã cập nhật $appliedCount ghi chú từ Supabase'
            : 'Không có ghi chú nào mới để đồng bộ';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đồng bộ thất bại: $error')));
      }
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ dữ liệu?'),
        content: const Text(
          'Toàn bộ giao dịch đã lưu trên máy sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa tất cả', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(transactionRepositoryProvider).deleteAll();
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardSummaryProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu')));
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final transactions = await ref.read(transactionRepositoryProvider).getTransactions();
    if (transactions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chưa có giao dịch nào để export')));
      }
      return;
    }

    try {
      final csvContent = CsvTransactionCodec.encode(transactions);
      final fileName = 'thu_chi_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(utf8.encode(csvContent), mimeType: 'text/csv')],
          fileNameOverrides: [fileName],
          subject: fileName,
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chia sẻ file: $error')));
      }
    }
  }

  Future<void> _importCsv(BuildContext context, WidgetRef ref) async {
    const typeGroup = XTypeGroup(label: 'CSV', extensions: ['csv']);

    final XFile? file;
    final String content;
    try {
      file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;
      content = await file.readAsString();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể đọc file: $error')));
      }
      return;
    }

    final transactions = CsvTransactionCodec.decode(content);
    if (transactions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không đọc được giao dịch nào từ file này')));
      }
      return;
    }

    final repository = ref.read(transactionRepositoryProvider);
    final countBefore = (await repository.getTransactions()).length;
    for (final transaction in transactions) {
      await repository.insert(transaction);
    }
    final countAfter = (await repository.getTransactions()).length;
    final addedCount = countAfter - countBefore;
    final skippedCount = transactions.length - addedCount;

    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardSummaryProvider);

    if (context.mounted) {
      final message = skippedCount > 0
          ? 'Đã thêm $addedCount giao dịch mới (bỏ qua $skippedCount giao dịch trùng lặp)'
          : 'Đã thêm $addedCount giao dịch mới';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: '1.0.0',
      children: const [
        SizedBox(height: 12),
        Text(
          'Đọc thông báo biến động số dư từ VietinBank iPay ngay trên máy, '
          'phân tích và thống kê thu chi.\n\n'
          'App không đăng nhập ngân hàng, không lưu mật khẩu/OTP, và không '
          'gửi bất kỳ dữ liệu giao dịch nào lên server — mọi thứ chỉ lưu local '
          'trên thiết bị của bạn.',
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54),
    );
  }
}
