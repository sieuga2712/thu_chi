import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/transaction_categories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../providers/category_settings_providers.dart';
import '../../../../providers/database_providers.dart';
import '../../../transactions/providers/transaction_list_provider.dart';

/// Cho phép xem và xóa hẳn một nhóm chi tiêu (tag) khỏi danh sách gợi ý —
/// gồm cả tag preset ([presetTransactionCategories]) lẫn tag tự gõ đã từng
/// dùng. Xóa một tag sẽ gỡ nó khỏi mọi giao dịch đang dùng (đặt lại rỗng) và
/// ẩn vĩnh viễn khỏi gợi ý sau này.
class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  List<String>? _tags;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = ref.read(transactionRepositoryProvider);
    final settings = ref.read(categorySettingsServiceProvider);

    final used = await repository.getDistinctCategories();
    final hidden = settings.getHiddenCategories();
    final all = {
      ...presetTransactionCategories,
      ...used,
    }.where((tag) => !hidden.contains(tag)).toList()..sort();

    if (!mounted) return;
    setState(() => _tags = all);
  }

  Future<void> _deleteTag(String tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa tag "$tag"?'),
        content: const Text(
          'Tag này sẽ bị gỡ khỏi mọi giao dịch đang dùng và không còn hiện trong '
          'gợi ý nữa. Hành động không thể hoàn tác.',
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

    final repository = ref.read(transactionRepositoryProvider);
    final settings = ref.read(categorySettingsServiceProvider);

    final affectedCount = await repository.clearCategory(tag);
    await settings.hideCategory(tag);
    ref.invalidate(allTransactionsProvider);

    await _load();

    if (!mounted) return;
    final message = affectedCount > 0
        ? 'Đã xóa tag "$tag" khỏi $affectedCount giao dịch'
        : 'Đã xóa tag "$tag"';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final tags = _tags;

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý nhóm chi tiêu')),
      body: tags == null
          ? const Center(child: CircularProgressIndicator())
          : tags.isEmpty
          ? const Center(child: Text('Chưa có nhóm chi tiêu nào'))
          : ListView.separated(
              itemCount: tags.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tag = tags[index];
                return ListTile(
                  title: Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: RetroStyle.fontFamily,
                      fontSize: 19,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.expense,
                    ),
                    tooltip: 'Xóa tag',
                    onPressed: () => _deleteTag(tag),
                  ),
                );
              },
            ),
    );
  }
}
