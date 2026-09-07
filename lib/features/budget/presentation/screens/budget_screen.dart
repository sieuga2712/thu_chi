import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../models/budget_config.dart';
import '../../../../models/budget_period.dart';
import '../../../../providers/budget_providers.dart';
import '../../../../providers/database_providers.dart';
import '../../logic/budget_progress_calculator.dart';

/// Ngân sách tổng (v1): một hạn mức chi tiêu duy nhất theo Tuần hoặc Tháng,
/// không chia theo từng nhóm chi tiêu. Tiến trình luôn tính trực tiếp từ
/// giao dịch trong kỳ hiện tại — không lưu trạng thái "đã dùng bao nhiêu"
/// riêng, tránh lệch với dữ liệu gốc khi giao dịch bị sửa/xóa sau đó.
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _loading = true;
  BudgetConfig? _config;
  int _spent = 0;

  bool _editing = false;
  BudgetPeriod _formPeriod = BudgetPeriod.day;
  final _limitController = TextEditingController(text: '200000');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = ref.read(budgetSettingsServiceProvider);
    final config = settings.getBudget();

    var spent = 0;
    if (config != null) {
      final repository = ref.read(transactionRepositoryProvider);
      final all = await repository.getTransactions();
      spent = computeSpentInCurrentPeriod(all, config);
    }

    if (!mounted) return;
    setState(() {
      _config = config;
      _spent = spent;
      _loading = false;
      _editing = config == null;
      if (config != null) {
        _formPeriod = config.period;
        _limitController.text = config.limitAmount.toString();
      }
    });
  }

  int? _parseLimit() {
    final digitsOnly = _limitController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return null;
    return int.tryParse(digitsOnly);
  }

  Future<void> _save() async {
    final limit = _parseLimit();
    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập hạn mức hợp lệ (lớn hơn 0)')),
      );
      return;
    }

    final settings = ref.read(budgetSettingsServiceProvider);
    await settings.setBudget(
      BudgetConfig(period: _formPeriod, limitAmount: limit),
    );
    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu ngân sách')));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ngân sách?'),
        content: const Text(
          'Bạn sẽ không còn thấy cảnh báo giới hạn chi tiêu nữa.',
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
    if (confirmed != true) return;

    final settings = ref.read(budgetSettingsServiceProvider);
    await settings.clearBudget();
    _limitController.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ngân sách')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!_editing && _config != null)
                  _buildProgress(context, _config!),
                if (!_editing && _config != null) const SizedBox(height: 16),
                if (!_editing && _config != null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _editing = true),
                          child: const Text('Sửa'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _confirmDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.expense,
                          ),
                          child: const Text('Xóa ngân sách'),
                        ),
                      ),
                    ],
                  ),
                if (_editing) _buildForm(context),
              ],
            ),
    );
  }

  Widget _buildProgress(BuildContext context, BudgetConfig config) {
    final ratio = config.limitAmount == 0 ? 0.0 : _spent / config.limitAmount;
    final remaining = config.limitAmount - _spent;
    final color = ratio >= 1
        ? AppColors.expense
        : ratio >= 0.8
        ? Colors.orange
        : AppColors.income;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ngân sách theo ${config.period.label.toLowerCase()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0, 1).toDouble(),
                minHeight: 12,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Đã chi: ${CurrencyFormatter.format(_spent)} / ${CurrencyFormatter.format(config.limitAmount)}',
              style: const TextStyle(
                fontFamily: RetroStyle.fontFamily,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              remaining >= 0
                  ? 'Còn lại: ${CurrencyFormatter.format(remaining)}'
                  : 'Đã vượt: ${CurrencyFormatter.format(-remaining)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: RetroStyle.fontFamily,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đặt hạn mức chi tiêu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: RetroStyle.fontFamily,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<BudgetPeriod>(
          segments: const [
            ButtonSegment(
              value: BudgetPeriod.day,
              label: Text(
                'Ngày',
                style: TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                ),
              ),
            ),
            ButtonSegment(
              value: BudgetPeriod.week,
              label: Text(
                'Tuần',
                style: TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                ),
              ),
            ),
            ButtonSegment(
              value: BudgetPeriod.month,
              label: Text(
                'Tháng',
                style: TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 18,
                ),
              ),
            ),
          ],
          selected: {_formPeriod},
          onSelectionChanged: (selection) =>
              setState(() => _formPeriod = selection.first),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('budget_limit_field'),
          controller: _limitController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
            labelText: 'Hạn mức (VND)',
            hintText: 'Ví dụ: 1500000',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_config != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _editing = false),
                  child: const Text('Hủy'),
                ),
              ),
            if (_config != null) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(onPressed: _save, child: const Text('Lưu')),
            ),
          ],
        ),
      ],
    );
  }
}
