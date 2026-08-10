import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/services/transaction_fingerprint.dart';

void main() {
  Transaction tx({
    String? account,
    int amount = 2000000,
    DateTime? time,
    String description = 'NGUYEN VAN A CHUYEN TIEN',
    int? balanceAfter = 15500000,
  }) {
    return Transaction(
      type: TransactionType.income,
      amount: amount,
      currency: 'VND',
      account: account ?? '****1234',
      description: description,
      balanceAfter: balanceAfter,
      transactionTime: time ?? DateTime(2026, 8, 10, 8, 30),
      rawNotification: 'raw',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  test('cùng dữ liệu giao dịch cho ra cùng một fingerprint', () {
    final a = TransactionFingerprint.of(tx());
    final b = TransactionFingerprint.of(tx());

    expect(a, b);
  });

  test('khác amount cho fingerprint khác nhau', () {
    final a = TransactionFingerprint.of(tx(amount: 2000000));
    final b = TransactionFingerprint.of(tx(amount: 2000001));

    expect(a, isNot(b));
  });

  test('khác transactionTime cho fingerprint khác nhau', () {
    final a = TransactionFingerprint.of(tx(time: DateTime(2026, 8, 10, 8, 30)));
    final b = TransactionFingerprint.of(tx(time: DateTime(2026, 8, 10, 8, 31)));

    expect(a, isNot(b));
  });

  test('khác account cho fingerprint khác nhau', () {
    final a = TransactionFingerprint.of(tx(account: '****1234'));
    final b = TransactionFingerprint.of(tx(account: '****5678'));

    expect(a, isNot(b));
  });

  test('khác description cho fingerprint khác nhau', () {
    final a = TransactionFingerprint.of(tx(description: 'A'));
    final b = TransactionFingerprint.of(tx(description: 'B'));

    expect(a, isNot(b));
  });

  test('khác balanceAfter cho fingerprint khác nhau', () {
    final a = TransactionFingerprint.of(tx(balanceAfter: 1000));
    final b = TransactionFingerprint.of(tx(balanceAfter: 2000));

    expect(a, isNot(b));
  });

  test('description chỉ khác hoa/thường hoặc khoảng trắng thừa vẫn ra cùng fingerprint', () {
    final a = TransactionFingerprint.of(tx(description: 'Nguyen Van A'));
    final b = TransactionFingerprint.of(tx(description: '  NGUYEN VAN A  '));

    expect(a, b);
  });

  test('fingerprint là chuỗi hex SHA-256 ổn định độ dài 64 ký tự', () {
    final value = TransactionFingerprint.of(tx());

    expect(value, hasLength(64));
    expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(value), isTrue);
  });

  test(
    'DateTime có mili-giây và DateTime cùng giây nhưng đã bị làm tròn '
    '(như khi đọc lại từ Drift) phải cho cùng một fingerprint',
    () {
      // Bug thật đã gặp: Drift lưu DateTimeColumn theo độ chính xác giây, nên
      // một Transaction "tươi" (postTime có mili-giây, ví dụ từ notification
      // native) và chính giao dịch đó sau khi đọc lại từ DB (mili-giây đã
      // mất) phải tính ra CÙNG fingerprint — nếu không, insertOrIgnore không
      // chặn được trùng lặp khi cùng một notification được xử lý hai lần.
      final withMillis = tx(time: DateTime(2026, 8, 10, 8, 30, 15, 987));
      final truncatedToSecond = tx(time: DateTime(2026, 8, 10, 8, 30, 15));

      expect(
        TransactionFingerprint.of(withMillis),
        TransactionFingerprint.of(truncatedToSecond),
      );
    },
  );
}
