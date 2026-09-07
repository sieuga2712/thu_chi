import 'budget_period.dart';

/// Cấu hình ngân sách tổng (v1: chỉ 1 hạn mức tổng, không chia theo nhóm chi
/// tiêu) — hạn mức chi tiêu tối đa cho một [period] (tuần hoặc tháng).
class BudgetConfig {
  const BudgetConfig({required this.period, required this.limitAmount});

  final BudgetPeriod period;
  final int limitAmount;

  Map<String, dynamic> toJson() => {
    'period': period.name,
    'limitAmount': limitAmount,
  };

  factory BudgetConfig.fromJson(Map<String, dynamic> json) {
    return BudgetConfig(
      period: BudgetPeriod.values.byName(json['period'] as String),
      limitAmount: json['limitAmount'] as int,
    );
  }
}
