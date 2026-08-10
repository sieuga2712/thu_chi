import '../models/transaction.dart';

/// Đồng bộ ghi chú giao dịch (Phase 11) giữa thiết bị và Supabase, khớp bằng
/// fingerprint (Phase 9). Interface trừu tượng để UI/provider không phụ
/// thuộc trực tiếp vào Supabase — dễ viết fake cho test, và dễ đổi backend
/// đồng bộ sau này nếu cần.
abstract class NoteSyncService {
  /// Đẩy note của [transaction] lên backend (upsert theo fingerprint).
  Future<void> pushNote(Transaction transaction);

  /// Kéo toàn bộ ghi chú từ backend về, khớp theo fingerprint với giao dịch
  /// local, và cập nhật local nếu khác. Trả về số ghi chú đã áp dụng.
  Future<int> pullAllNotes();
}
