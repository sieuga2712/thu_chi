import 'package:flutter/material.dart';

/// Hiển thị khi chưa có đủ dữ liệu để vẽ biểu đồ (ví dụ mới cài app, chưa
/// nhận notification nào).
class EmptyChartPlaceholder extends StatelessWidget {
  const EmptyChartPlaceholder({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart, size: 32, color: Colors.black26),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
