import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_query_provider.dart';

class TransactionSearchBar extends ConsumerStatefulWidget {
  const TransactionSearchBar({super.key});

  @override
  ConsumerState<TransactionSearchBar> createState() =>
      _TransactionSearchBarState();
}

class _TransactionSearchBarState extends ConsumerState<TransactionSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(transactionQueryProvider).searchText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(transactionQueryProvider.notifier).setSearchText('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) =>
          ref.read(transactionQueryProvider.notifier).setSearchText(value),
      decoration: InputDecoration(
        hintText: 'Tìm theo nội dung, số tiền, tài khoản...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(icon: const Icon(Icons.clear), onPressed: _clear);
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
