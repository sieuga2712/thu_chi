import 'package:drift/drift.dart';

import '../converters/transaction_type_converter.dart';

/// Bảng lưu trữ giao dịch đã được TransactionParser trích xuất (xem section 5
/// của spec). Đặt tên data class là `TransactionRow` (thay vì mặc định
/// `Transaction`) để không đụng với domain model `models/transaction.dart`.
///
/// `transactionCode` không nằm trong danh sách field tối thiểu của spec
/// nhưng đã có sẵn trong domain model từ Phase 4 — thêm vào đây để không mất
/// dữ liệu đã parser được.
///
/// `fingerprint` (Phase 9, section 6) chống trùng lặp giao dịch: unique index
/// đảm bảo cùng một giao dịch không thể được insert hai lần dù notification
/// bị xử lý lại. Cột để nullable ở tầng schema vì SQLite không cho phép
/// `ALTER TABLE ADD COLUMN` với ràng buộc NOT NULL trên bảng đã có dữ liệu —
/// ở tầng ứng dụng, [DriftTransactionRepository] luôn tính và gán giá trị
/// này cho mọi lần insert.
@DataClassName('TransactionRow')
@TableIndex(
  name: 'transactions_fingerprint_idx',
  columns: {#fingerprint},
  unique: true,
)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get transactionType =>
      text().map(const TransactionTypeConverter())();

  IntColumn get amount => integer()();
  TextColumn get currency => text().withDefault(const Constant('VND'))();
  TextColumn get account => text().nullable()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get balanceAfter => integer().nullable()();
  DateTimeColumn get transactionTime => dateTime()();
  TextColumn get transactionCode => text().nullable()();

  /// Toàn bộ nội dung notification gốc — dùng để debug parser.
  TextColumn get rawNotification => text()();
  TextColumn get sourcePackage => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get fingerprint => text().nullable()();

  /// Ghi chú cá nhân do người dùng tự gõ (Phase 11) — đồng bộ qua Supabase
  /// bằng [fingerprint] làm khóa, KHÔNG đồng bộ account/rawNotification.
  /// Không null (mặc định rỗng, giống [description]) — SQLite cho phép
  /// `ALTER TABLE ADD COLUMN` kèm `DEFAULT ''` áp cho toàn bộ dòng cũ ngay,
  /// không cần backfill thủ công như [fingerprint].
  TextColumn get note => text().withDefault(const Constant(''))();

  /// Nhóm chi tiêu do người dùng tự gán (ví dụ "Ăn vặt", "Xăng xe") — nhập
  /// tự do, chỉ lưu local, KHÔNG đồng bộ Supabase (khác [note]).
  TextColumn get category => text().withDefault(const Constant(''))();
}
