import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../repositories/drift_transaction_repository.dart';
import '../repositories/transaction_repository.dart';

/// Instance database duy nhất cho toàn app, tự đóng kết nối khi provider bị
/// dispose (chỉ xảy ra khi container gốc bị hủy, tức khi app thoát).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Điểm truy cập duy nhất tới [TransactionRepository] trong cây provider —
/// UI/state luôn phụ thuộc vào interface này, không phụ thuộc Drift trực tiếp.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftTransactionRepository(db);
});
