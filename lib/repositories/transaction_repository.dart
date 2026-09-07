import '../models/transaction.dart';

/// Trừu tượng hoá tầng lưu trữ giao dịch. Các provider/UI chỉ nên phụ thuộc
/// vào interface này, không phụ thuộc trực tiếp vào Drift — nhờ vậy có thể
/// đổi công nghệ lưu trữ hoặc viết fake repository cho test mà không đụng gì
/// đến tầng UI.
abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<Transaction?> getById(int id);
  Future<void> insert(Transaction transaction);
  Future<void> delete(int id);
  Future<void> deleteAll();

  /// Cập nhật ghi chú cá nhân (Phase 11) cho giao dịch [id]. Không đụng đến
  /// bất kỳ trường nào khác của giao dịch.
  Future<void> updateNote(int id, String note);

  /// Cập nhật nhóm chi tiêu cho giao dịch [id]. Không đụng đến bất kỳ trường
  /// nào khác của giao dịch.
  Future<void> updateCategory(int id, String category);

  /// Danh sách các nhóm chi tiêu (khác rỗng) đã từng được gán, không trùng
  /// lặp — dùng làm gợi ý tự động hoàn thành khi người dùng gõ nhóm mới.
  Future<List<String>> getDistinctCategories();

  /// Gỡ nhóm chi tiêu [category] khỏi mọi giao dịch đang dùng nó (đặt lại
  /// thành rỗng), dùng khi người dùng xóa hẳn một tag ở màn hình quản lý.
  /// Trả về số giao dịch bị ảnh hưởng.
  Future<int> clearCategory(String category);
}
