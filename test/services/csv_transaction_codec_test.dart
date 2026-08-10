import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/services/csv_transaction_codec.dart';

void main() {
  final income = Transaction(
    type: TransactionType.income,
    amount: 2000000,
    currency: 'VND',
    account: '****1234',
    description: 'NGUYEN VAN A CHUYEN TIEN',
    balanceAfter: 15500000,
    transactionTime: DateTime(2026, 8, 10, 8, 30),
    transactionCode: 'FT26224001',
    rawNotification: 'TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A CHUYEN TIEN\nSD: 15,500,000 VND',
    sourcePackage: 'com.vietinbank.ipay',
  );

  final expense = Transaction(
    type: TransactionType.expense,
    amount: 350000,
    currency: 'VND',
    account: null,
    description: 'THANH TOAN, CAFE "Highlands"',
    balanceAfter: null,
    transactionTime: DateTime(2026, 8, 9),
    transactionCode: null,
    rawNotification: 'TK -350,000 VND',
    sourcePackage: 'com.vietinbank.ipay',
  );

  test('encode rồi decode trả về đúng dữ liệu ban đầu (round-trip)', () {
    final csv = CsvTransactionCodec.encode([income, expense]);
    final decoded = CsvTransactionCodec.decode(csv);

    expect(decoded, hasLength(2));
    expect(decoded[0].type, income.type);
    expect(decoded[0].amount, income.amount);
    expect(decoded[0].account, income.account);
    expect(decoded[0].description, income.description);
    expect(decoded[0].balanceAfter, income.balanceAfter);
    expect(decoded[0].transactionTime, income.transactionTime);
    expect(decoded[0].transactionCode, income.transactionCode);
  });

  test('trường có dấu phẩy/dấu ngoặc kép trong nội dung vẫn round-trip đúng', () {
    final csv = CsvTransactionCodec.encode([expense]);
    final decoded = CsvTransactionCodec.decode(csv);

    expect(decoded.single.description, 'THANH TOAN, CAFE "Highlands"');
  });

  test('account/balanceAfter/transactionCode null được giữ null sau khi decode', () {
    final csv = CsvTransactionCodec.encode([expense]);
    final decoded = CsvTransactionCodec.decode(csv);

    expect(decoded.single.account, isNull);
    expect(decoded.single.balanceAfter, isNull);
    expect(decoded.single.transactionCode, isNull);
  });

  test('chuỗi rỗng trả về danh sách rỗng, không crash', () {
    expect(CsvTransactionCodec.decode(''), isEmpty);
  });

  test('chỉ có header, không có dòng dữ liệu -> danh sách rỗng', () {
    final csv = CsvTransactionCodec.encode(const []);
    expect(CsvTransactionCodec.decode(csv), isEmpty);
  });

  test('dòng thiếu trường bắt buộc (amount) bị bỏ qua, không làm hỏng cả file', () {
    final csv =
        '${CsvTransactionCodec.header.join(",")}\n'
        'income,,VND,,test,,${DateTime(2026, 1, 1).toIso8601String()},,pkg,raw\n'
        '${CsvTransactionCodec.header.map((h) => h == "type"
            ? "expense"
            : h == "amount"
            ? "1000"
            : h == "transactionTime"
            ? DateTime(2026, 1, 2).toIso8601String()
            : "").join(",")}';

    final decoded = CsvTransactionCodec.decode(csv);

    expect(decoded, hasLength(1));
    expect(decoded.single.amount, 1000);
  });

  test('giá trị type không hợp lệ bị bỏ qua', () {
    final csv =
        '${CsvTransactionCodec.header.join(",")}\n'
        'khong_ton_tai,1000,VND,,,,${DateTime(2026, 1, 1).toIso8601String()},,,';

    expect(CsvTransactionCodec.decode(csv), isEmpty);
  });
}
