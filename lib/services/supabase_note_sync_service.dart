import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import 'note_sync_service.dart';
import 'transaction_fingerprint.dart';

/// Cài đặt [NoteSyncService] bằng Supabase — KHÔNG gửi account/rawNotification,
/// chỉ note + vài metadata để nhận diện giao dịch khi xem qua Supabase Table
/// Editor (xem supabase/schema.sql).
///
/// Chiến lược đồng bộ cố tình đơn giản, phù hợp app cá nhân 1 người dùng
/// dùng trên vài thiết bị:
/// - [pushNote] gọi ngay sau khi lưu note local — best-effort, lỗi mạng
///   không làm mất note local (đã lưu trước rồi).
/// - [pullAllNotes] chỉ chạy khi người dùng chủ động bấm "Đồng bộ" ở Settings
///   — không tự động ghi đè local lúc mở app, tránh mất note vừa sửa mà
///   chưa kịp push thành công.
class SupabaseNoteSyncService implements NoteSyncService {
  SupabaseNoteSyncService({required SupabaseClient client, required TransactionRepository repository})
    : _client = client,
      _repository = repository;

  final SupabaseClient _client;
  final TransactionRepository _repository;

  @override
  Future<void> pushNote(Transaction transaction) async {
    final fingerprint = TransactionFingerprint.of(transaction);
    await _client.from(SupabaseConfig.notesTable).upsert({
      'fingerprint': fingerprint,
      'note': transaction.note,
      'amount': transaction.amount,
      'transaction_type': transaction.type.name,
      'transaction_time': transaction.transactionTime.toIso8601String(),
    }, onConflict: 'fingerprint');
  }

  @override
  Future<int> pullAllNotes() async {
    final rows = await _client.from(SupabaseConfig.notesTable).select('fingerprint, note');

    final remoteByFingerprint = <String, String>{};
    for (final row in (rows as List).cast<Map<String, dynamic>>()) {
      final fingerprint = row['fingerprint'] as String?;
      if (fingerprint == null) continue;
      remoteByFingerprint[fingerprint] = row['note'] as String? ?? '';
    }
    if (remoteByFingerprint.isEmpty) return 0;

    final localTransactions = await _repository.getTransactions();
    var appliedCount = 0;
    for (final transaction in localTransactions) {
      final id = transaction.id;
      if (id == null) continue;

      final fingerprint = TransactionFingerprint.of(transaction);
      final remoteNote = remoteByFingerprint[fingerprint];
      if (remoteNote != null && remoteNote != transaction.note) {
        await _repository.updateNote(id, remoteNote);
        appliedCount++;
      }
    }
    return appliedCount;
  }
}
