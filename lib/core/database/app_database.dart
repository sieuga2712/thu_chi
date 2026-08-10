import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../models/transaction_type.dart';
import '../../services/transaction_fingerprint.dart';
import 'converters/transaction_type_converter.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

/// Database SQLite của app, chỉ lưu local trên thiết bị (xem section 1 —
/// không đồng bộ, không gửi lên server).
@DriftDatabase(tables: [Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Dùng cho test: truyền thẳng một executor (ví dụ `NativeDatabase.memory()`)
  /// thay vì mở file thật trên đĩa.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            // Phase 9: thêm cột fingerprint chống trùng lặp giao dịch.
            // SQLite không cho ALTER TABLE ADD COLUMN kèm ràng buộc UNIQUE
            // trên bảng đã có dữ liệu, nên thêm cột trước (nullable), backfill
            // dữ liệu cũ, rồi mới tạo unique index riêng.
            await migrator.addColumn(transactions, transactions.fingerprint);

            final existingRows = await select(transactions).get();
            for (final row in existingRows) {
              final fingerprint = TransactionFingerprint.compute(
                account: row.account,
                amount: row.amount,
                transactionTime: row.transactionTime,
                description: row.description,
                balanceAfter: row.balanceAfter,
              );
              await (update(transactions)..where((t) => t.id.equals(row.id))).write(
                TransactionsCompanion(fingerprint: Value(fingerprint)),
              );
            }

            await migrator.createIndex(transactionsFingerprintIdx);
          }
        },
      );
}

// Từ package:sqlite3 v3.x, thư viện native SQLite được tự động bundle qua
// Dart hooks/native-assets — không còn cần workaround thủ công cho Android
// như các phiên bản sqlite3_flutter_libs cũ nữa.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(path.join(documentsDir.path, 'thu_chi.db'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
