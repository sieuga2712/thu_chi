import 'package:drift/drift.dart';

import '../core/database/app_database.dart';
import '../models/transaction.dart' as domain;
import '../services/transaction_fingerprint.dart';
import 'transaction_repository.dart';

/// Cài đặt [TransactionRepository] bằng Drift/SQLite.
class DriftTransactionRepository implements TransactionRepository {
  DriftTransactionRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<domain.Transaction>> getTransactions() async {
    final query = _db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.transactionTime)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<domain.Transaction?> getById(int id) async {
    final query = _db.select(_db.transactions)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> insert(domain.Transaction transaction) async {
    // insertOrIgnore: nếu fingerprint đã tồn tại (unique index, Phase 9),
    // SQLite tự bỏ qua insert thay vì throw — chống trùng lặp giao dịch
    // trong suốt, không cần bên gọi tự kiểm tra trước.
    await _db
        .into(_db.transactions)
        .insert(_toCompanion(transaction), mode: InsertMode.insertOrIgnore);
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteAll() async {
    await _db.delete(_db.transactions).go();
  }

  domain.Transaction _toDomain(TransactionRow row) {
    return domain.Transaction(
      id: row.id,
      type: row.transactionType,
      amount: row.amount,
      currency: row.currency,
      account: row.account,
      description: row.description,
      balanceAfter: row.balanceAfter,
      transactionTime: row.transactionTime,
      transactionCode: row.transactionCode,
      rawNotification: row.rawNotification,
      sourcePackage: row.sourcePackage,
    );
  }

  TransactionsCompanion _toCompanion(domain.Transaction transaction) {
    return TransactionsCompanion.insert(
      transactionType: transaction.type,
      amount: transaction.amount,
      currency: Value(transaction.currency),
      account: Value(transaction.account),
      description: Value(transaction.description),
      balanceAfter: Value(transaction.balanceAfter),
      transactionTime: transaction.transactionTime,
      transactionCode: Value(transaction.transactionCode),
      rawNotification: transaction.rawNotification,
      sourcePackage: transaction.sourcePackage,
      fingerprint: Value(TransactionFingerprint.of(transaction)),
    );
  }
}
