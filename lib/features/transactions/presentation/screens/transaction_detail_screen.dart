import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/transaction_categories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/transaction.dart';
import '../../../../models/transaction_type.dart';
import '../../../../providers/category_settings_providers.dart';
import '../../../../providers/database_providers.dart';
import '../../../../providers/supabase_providers.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../providers/transaction_list_provider.dart';

/// Chi tiết một giao dịch (section 9). Có tùy chọn xóa giao dịch, ghi chú
/// cá nhân đồng bộ qua Supabase (Phase 11), và nhóm chi tiêu tự gán chỉ lưu
/// local (không đồng bộ).
class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  late final TextEditingController _noteController;
  late final TextEditingController _categoryController;
  late Transaction _transaction;
  bool _saving = false;
  List<String> _categorySuggestions = const [];

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
    _noteController = TextEditingController(text: _transaction.note);
    _categoryController = TextEditingController(text: _transaction.category);
    _loadCategorySuggestions();
  }

  Future<void> _loadCategorySuggestions() async {
    final repository = ref.read(transactionRepositoryProvider);
    final settings = ref.read(categorySettingsServiceProvider);
    final existing = await repository.getDistinctCategories();
    final hidden = settings.getHiddenCategories();
    if (!mounted) return;
    setState(() {
      _categorySuggestions = {
        ...presetTransactionCategories,
        ...existing,
      }.where((tag) => !hidden.contains(tag)).toList()..sort();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  bool get _noteChanged => _noteController.text != _transaction.note;
  bool get _categoryChanged =>
      _categoryController.text != _transaction.category;
  bool get _hasChanges => _noteChanged || _categoryChanged;

  @override
  Widget build(BuildContext context) {
    final isIncome = _transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa giao dịch',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(
              CurrencyFormatter.formatSigned(
                _transaction.amount,
                isIncome: isIncome,
                currency: _transaction.currency,
              ),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Loại',
                    value: isIncome ? 'Tiền vào' : 'Tiền ra',
                  ),
                  _DetailRow(
                    label: 'Thời gian',
                    value: AppDateFormatter.formatDateTime(
                      _transaction.transactionTime,
                    ),
                  ),
                  _DetailRow(
                    label: 'Tài khoản',
                    value: _transaction.account ?? '—',
                  ),
                  _DetailRow(
                    label: 'Số dư sau giao dịch',
                    value: _transaction.balanceAfter != null
                        ? CurrencyFormatter.format(
                            _transaction.balanceAfter!,
                            currency: _transaction.currency,
                          )
                        : '—',
                  ),
                  if (_transaction.transactionCode != null)
                    _DetailRow(
                      label: 'Mã giao dịch',
                      value: _transaction.transactionCode!,
                    ),
                  if (_transaction.sourcePackage ==
                      AppConfig.manualEntrySourcePackage)
                    const _DetailRow(label: 'Nguồn', value: 'Nhập thủ công'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nội dung',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: RetroStyle.fontFamily,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _transaction.description.isEmpty
                    ? '(Không có nội dung)'
                    : _transaction.description,
                style: const TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nhóm chi tiêu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: RetroStyle.fontFamily,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('category_field'),
            controller: _categoryController,
            style: const TextStyle(
              fontFamily: RetroStyle.fontFamily,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Ăn vặt, Xăng xe... (tự gõ nhóm mới cũng được)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_categorySuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _categorySuggestions.map((category) {
                return ActionChip(
                  label: Text(category),
                  onPressed: () =>
                      setState(() => _categoryController.text = category),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Ghi chú của bạn',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    'Ghi chú được đồng bộ lên Supabase (chỉ note + số tiền/ngày, '
                    'không gửi tài khoản hay nội dung notification gốc) để bạn '
                    'xem/sửa được từ máy tính qua Supabase Table Editor. Nhóm chi '
                    'tiêu chỉ lưu trên máy, không đồng bộ.',
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('note_field'),
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(
              fontFamily: RetroStyle.fontFamily,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              hintText: 'Ví dụ: tiền ăn trưa với đồng nghiệp...',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _hasChanges && !_saving ? () => _save(context) : null,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Lưu'),
            ),
          ),
          // Đệm rỗng dưới cùng: một số máy có thanh cử chỉ/phím home ảo che
          // mất nút Lưu nếu cuộn hết xuống đáy mà không chừa khoảng trống.
          SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final id = _transaction.id;
    if (id == null) return;

    setState(() => _saving = true);

    final noteChanged = _noteChanged;
    final categoryChanged = _categoryChanged;
    final newNote = _noteController.text;
    final newCategory = _categoryController.text;
    final repository = ref.read(transactionRepositoryProvider);
    if (noteChanged) await repository.updateNote(id, newNote);
    if (categoryChanged) await repository.updateCategory(id, newCategory);

    final updated = _transaction.copyWith(note: newNote, category: newCategory);
    setState(() {
      _transaction = updated;
      _saving = false;
    });

    ref.invalidate(allTransactionsProvider);
    if (categoryChanged) unawaited(_loadCategorySuggestions());

    if (!context.mounted) return;

    if (!noteChanged) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu')));
      return;
    }

    try {
      await ref.read(noteSyncServiceProvider).pushNote(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu ghi chú và đồng bộ lên Supabase'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã lưu ghi chú local — đồng bộ Supabase thất bại: $error',
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text(
          'Giao dịch này sẽ bị xóa khỏi lịch sử. Hành động không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || _transaction.id == null) return;

    final repository = ref.read(transactionRepositoryProvider);
    await repository.delete(_transaction.id!);
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardSummaryProvider);

    if (context.mounted) Navigator.of(context).pop();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontFamily: RetroStyle.fontFamily,
              fontSize: 17,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
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
