import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/notification_data.dart';
import '../../../../models/transaction.dart';
import '../../../../models/transaction_type.dart';
import '../../../../providers/database_providers.dart';
import '../../../../services/transaction_parser.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../providers/transaction_list_provider.dart';

/// Cho phép người dùng tự thêm một giao dịch bằng cách dán nguyên văn nội
/// dung thông báo ngân hàng (ví dụ copy được từ thông báo đã bị xóa hoặc bỏ
/// lỡ). Dùng lại đúng [TransactionParser] của luồng tự động — cùng định dạng
/// mà notification thật gửi tới thì parse ra kết quả giống hệt nhau — và dựa
/// vào unique index trên fingerprint (Phase 9) để tự chống trùng khi insert,
/// không cần logic chống trùng riêng.
class ManualTransactionEntryScreen extends ConsumerStatefulWidget {
  const ManualTransactionEntryScreen({super.key});

  @override
  ConsumerState<ManualTransactionEntryScreen> createState() =>
      _ManualTransactionEntryScreenState();
}

class _ManualTransactionEntryScreenState
    extends ConsumerState<ManualTransactionEntryScreen> {
  final _controller = TextEditingController();
  final _parser = const TransactionParser();

  Transaction? _preview;
  String? _parseError;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final notification = NotificationData(
      packageName: AppConfig.manualEntrySourcePackage,
      title: '',
      text: raw,
      postTime: DateTime.now(),
      capturedAt: DateTime.now(),
      notificationKey: 'manual-${DateTime.now().microsecondsSinceEpoch}',
    );

    final parsed = _parser.parse(notification);
    setState(() {
      _preview = parsed;
      _parseError = parsed == null
          ? 'Không đọc được giao dịch từ nội dung này. Kiểm tra lại đã dán đủ '
                'số tiền, loại giao dịch (+/-) và định dạng có giống thông báo '
                'ngân hàng gốc không.'
          : null;
    });
  }

  void _editAgain() {
    setState(() {
      _preview = null;
      _parseError = null;
    });
  }

  Future<void> _confirmAdd() async {
    final transaction = _preview;
    if (transaction == null) return;

    setState(() => _saving = true);

    final repository = ref.read(transactionRepositoryProvider);
    final countBefore = (await repository.getTransactions()).length;
    await repository.insert(transaction);
    final countAfter = (await repository.getTransactions()).length;
    final wasAdded = countAfter > countBefore;

    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardSummaryProvider);

    if (!mounted) return;

    setState(() {
      _saving = false;
      _controller.clear();
      _preview = null;
      _parseError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasAdded
              ? 'Đã thêm giao dịch'
              : 'Giao dịch này trùng với giao dịch đã có — không thêm lại',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch thủ công')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Dán nguyên văn nội dung thông báo ngân hàng (copy được từ thông '
            'báo đã bỏ lỡ hoặc bị xóa). Ví dụ định dạng:',
            style: TextStyle(fontFamily: RetroStyle.fontFamily, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TK 104878432165 -35,000 VND\n'
              'ND: NGUYEN MINH QUANG Chuyen tien; tai iPay\n'
              'SD: 15,500,000 VND',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('manual_entry_field'),
            controller: _controller,
            maxLines: 6,
            style: const TextStyle(
              fontFamily: RetroStyle.fontFamily,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              hintText: 'Dán nội dung thông báo ở đây...',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {
              _preview = null;
              _parseError = null;
            }),
          ),
          const SizedBox(height: 12),
          if (preview == null)
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _controller.text.trim().isEmpty ? null : _analyze,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Phân tích'),
              ),
            ),
          if (_parseError != null) ...[
            const SizedBox(height: 12),
            Text(
              _parseError!,
              style: const TextStyle(
                color: AppColors.expense,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 18,
              ),
            ),
          ],
          if (preview != null) ...[
            const SizedBox(height: 20),
            Text(
              'Xem trước',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            _PreviewCard(transaction: preview),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _editAgain,
                    child: const Text('Sửa lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _confirmAdd,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add, size: 18),
                    label: const Text('Thêm giao dịch'),
                  ),
                ),
              ],
            ),
          ],
          // Đệm rỗng dưới cùng: một số máy có thanh cử chỉ/phím home ảo che
          // mất nút Thêm giao dịch nếu cuộn hết xuống đáy mà không chừa
          // khoảng trống.
          SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CurrencyFormatter.formatSigned(
                transaction.amount,
                isIncome: isIncome,
                currency: transaction.currency,
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            _PreviewRow(
              label: 'Loại',
              value: isIncome ? 'Tiền vào' : 'Tiền ra',
            ),
            _PreviewRow(
              label: 'Thời gian',
              value: AppDateFormatter.formatDateTime(
                transaction.transactionTime,
              ),
            ),
            _PreviewRow(
              label: 'Nội dung',
              value: transaction.description.isEmpty
                  ? '(Không có nội dung)'
                  : transaction.description,
            ),
            if (transaction.account != null)
              _PreviewRow(label: 'Tài khoản', value: transaction.account!),
            if (transaction.balanceAfter != null)
              _PreviewRow(
                label: 'Số dư sau giao dịch',
                value: CurrencyFormatter.format(
                  transaction.balanceAfter!,
                  currency: transaction.currency,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 17,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
