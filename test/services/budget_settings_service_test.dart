import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/models/budget_config.dart';
import 'package:thu_chi/models/budget_period.dart';
import 'package:thu_chi/services/budget_settings_service.dart';

void main() {
  late BudgetSettingsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = BudgetSettingsService(prefs);
  });

  test('chưa đặt ngân sách thì trả về null', () {
    expect(service.getBudget(), isNull);
  });

  test('setBudget rồi getBudget đọc lại đúng period và limitAmount', () async {
    await service.setBudget(const BudgetConfig(period: BudgetPeriod.month, limitAmount: 5000000));

    final result = service.getBudget();

    expect(result!.period, BudgetPeriod.month);
    expect(result.limitAmount, 5000000);
  });

  test('setBudget lần sau ghi đè lần trước', () async {
    await service.setBudget(const BudgetConfig(period: BudgetPeriod.week, limitAmount: 300000));
    await service.setBudget(const BudgetConfig(period: BudgetPeriod.month, limitAmount: 5000000));

    final result = service.getBudget();

    expect(result!.period, BudgetPeriod.month);
    expect(result.limitAmount, 5000000);
  });

  test('clearBudget xóa cấu hình, getBudget trả về null', () async {
    await service.setBudget(const BudgetConfig(period: BudgetPeriod.week, limitAmount: 300000));
    await service.clearBudget();

    expect(service.getBudget(), isNull);
  });
}
