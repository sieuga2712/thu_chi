import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/note_sync_service.dart';
import '../services/supabase_note_sync_service.dart';
import 'database_providers.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final noteSyncServiceProvider = Provider<NoteSyncService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final repository = ref.watch(transactionRepositoryProvider);
  return SupabaseNoteSyncService(client: client, repository: repository);
});
