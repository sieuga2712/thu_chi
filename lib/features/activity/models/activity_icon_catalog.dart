import 'package:flutter/material.dart';

/// 1 icon trong catalog — [key] là thứ được lưu vào [ActivityDefinition.icon]
/// (không lưu [IconData] trực tiếp vì codePoint dễ vỡ giữa các version).
class ActivityIconOption {
  const ActivityIconOption({
    required this.key,
    required this.icon,
    required this.label,
  });

  final String key;
  final IconData icon;
  final String label;
}

/// Danh sách icon cố định cho hoạt động checkbox — đủ dùng cho các thói
/// quen phổ biến, không cho phép upload icon tùy ý (giữ đơn giản).
class ActivityIconCatalog {
  ActivityIconCatalog._();

  static const options = <ActivityIconOption>[
    ActivityIconOption(key: 'run', icon: Icons.directions_run, label: 'Chạy bộ'),
    ActivityIconOption(key: 'book', icon: Icons.menu_book, label: 'Đọc sách'),
    ActivityIconOption(key: 'work', icon: Icons.work_outline, label: 'Công việc'),
    ActivityIconOption(key: 'luggage', icon: Icons.luggage, label: 'Chuẩn bị đồ'),
    ActivityIconOption(key: 'water', icon: Icons.water_drop, label: 'Uống nước'),
    ActivityIconOption(key: 'sleep', icon: Icons.bedtime, label: 'Ngủ'),
    ActivityIconOption(
      key: 'meditate',
      icon: Icons.self_improvement,
      label: 'Thiền',
    ),
    ActivityIconOption(key: 'food', icon: Icons.restaurant, label: 'Ăn uống'),
    ActivityIconOption(key: 'study', icon: Icons.school, label: 'Học tập'),
    ActivityIconOption(key: 'gym', icon: Icons.fitness_center, label: 'Gym'),
    ActivityIconOption(key: 'write', icon: Icons.edit, label: 'Viết'),
    ActivityIconOption(
      key: 'clean',
      icon: Icons.cleaning_services,
      label: 'Dọn nhà',
    ),
    ActivityIconOption(key: 'car', icon: Icons.directions_car, label: 'Xe cộ'),
    ActivityIconOption(
      key: 'wallet',
      icon: Icons.account_balance_wallet,
      label: 'Ví tiền',
    ),
    ActivityIconOption(key: 'health', icon: Icons.favorite, label: 'Sức khỏe'),
    ActivityIconOption(key: 'task', icon: Icons.checklist, label: 'Việc cần làm'),
  ];

  /// Icon mặc định khi hoạt động chưa chọn hoặc key không tồn tại (dữ liệu
  /// cũ/hỏng) — tránh crash khi tra cứu.
  static const fallback = ActivityIconOption(
    key: 'task',
    icon: Icons.checklist,
    label: 'Việc cần làm',
  );

  static IconData iconFor(String? key) {
    if (key == null) return fallback.icon;
    return options.firstWhere((o) => o.key == key, orElse: () => fallback).icon;
  }
}
