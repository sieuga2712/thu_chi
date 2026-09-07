import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/activity_storage_service.dart';
import 'category_settings_providers.dart';

final activityStorageServiceProvider = Provider<ActivityStorageService>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ActivityStorageService(prefs);
});
