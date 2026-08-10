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
}
