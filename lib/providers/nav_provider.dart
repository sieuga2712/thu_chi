import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index của tab đang chọn trên thanh bottom navigation của [AppShell].
class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

final navIndexProvider = NotifierProvider<NavIndexNotifier, int>(
  NavIndexNotifier.new,
);
