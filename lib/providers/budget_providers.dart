import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/budget_settings_service.dart';
import 'category_settings_providers.dart';

final budgetSettingsServiceProvider = Provider<BudgetSettingsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BudgetSettingsService(prefs);
});
