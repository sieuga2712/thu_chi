import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/services/note_sync_service.dart';

/// Bản giả của [NoteSyncService] dùng cho test, không chạm vào Supabase thật.
class FakeNoteSyncService implements NoteSyncService {
  final List<Transaction> pushedNotes = [];
  int pullCallCount = 0;
  int pullResult = 0;
  Object? pushError;
  Object? pullError;

  @override
  Future<void> pushNote(Transaction transaction) async {
    if (pushError != null) throw pushError!;
    pushedNotes.add(transaction);
  }

  @override
  Future<int> pullAllNotes() async {
    pullCallCount++;
    if (pullError != null) throw pullError!;
    return pullResult;
  }
}
