import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/transactions/presentation/screens/transaction_list_screen.dart';
import 'providers/nav_provider.dart';
import 'providers/notification_pipeline_provider.dart';

/// Scaffold gốc: điều hướng bottom navigation giữa ba tab chính.
///
/// Tổng quan | Giao dịch | Cài đặt
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = <Widget>[
    DashboardScreen(),
    TransactionListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    // Giữ pipeline notification -> parser -> DB luôn sống trong suốt vòng
    // đời app, không phụ thuộc tab nào đang mở. Không dùng giá trị trả về ở
    // đây — chỉ cần provider được khởi tạo và không bị dispose.
    ref.watch(notificationPipelineProvider);

    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) =>
            ref.read(navIndexProvider.notifier).set(value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
