import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/models/notification_data.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/services/transaction_parser.dart';

void main() {
  final parser = const TransactionParser();

  NotificationData notif({
    String title = 'VietinBank',
    required String text,
    String packageName = 'com.vietinbank.ipay',
    DateTime? postTime,
  }) {
    final time = postTime ?? DateTime(2026, 8, 10, 8, 30);
    return NotificationData(
      packageName: packageName,
      title: title,
      text: text,
      bigText: text,
      subText: null,
      postTime: time,
      capturedAt: time,
      notificationKey: 'key-1',
    );
  }

  test('parse thông báo tiền vào (income) đúng ví dụ trong spec', () {
    final result = parser.parse(
      notif(
        text: 'TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A CHUYEN TIEN\nSD: 15,500,000 VND',
      ),
    );

    expect(result, isNotNull);
    expect(result!.type, TransactionType.income);
    expect(result.amount, 2000000);
    expect(result.currency, 'VND');
    expect(result.account, '****1234');
    expect(result.description, 'NGUYEN VAN A CHUYEN TIEN');
    expect(result.balanceAfter, 15500000);
  });

  test('parse thông báo tiền ra (expense) đúng ví dụ trong spec', () {
    final result = parser.parse(
      notif(
        text: 'TK ****1234 -350,000 VND\nND: THANH TOAN CAFE\nSD: 15,150,000 VND',
      ),
    );

    expect(result, isNotNull);
    expect(result!.type, TransactionType.expense);
    expect(result.amount, 350000);
    expect(result.account, '****1234');
    expect(result.description, 'THANH TOAN CAFE');
    expect(result.balanceAfter, 15150000);
  });

  test('notification không phải giao dịch trả về null', () {
    final result = parser.parse(
      notif(text: 'Ưu đãi tháng 8 dành cho bạn: giảm 50% phí thường niên thẻ tín dụng.'),
    );

    expect(result, isNull);
  });

  test('format sai/dị hình không crash, trả về null', () {
    final result = parser.parse(notif(text: '@#\$%^&*() TK ---- ??? ND'));

    expect(result, isNull);
  });

  test('notification rỗng không crash, trả về null', () {
    final result = parser.parse(notif(text: ''));

    expect(result, isNull);
  });

  test('amount có dấu phẩy làm phân cách hàng nghìn', () {
    final result = parser.parse(notif(text: 'TK ****9999 +12,345,000 VND\nND: LUONG THANG 8'));

    expect(result!.amount, 12345000);
  });

  test('amount có dấu chấm làm phân cách hàng nghìn (định dạng VN)', () {
    final result = parser.parse(notif(text: 'TK ****9999 -1.500.000 VND\nND: MUA SAM'));

    expect(result!.amount, 1500000);
  });

  test('trích xuất được số tài khoản đã che dạng số-sao', () {
    final result = parser.parse(notif(text: 'TK 1234**** +500,000 VND\nND: HOAN TIEN'));

    expect(result!.account, '1234****');
  });

  test('trích xuất được số dư khi có', () {
    final result = parser.parse(
      notif(text: 'TK ****1234 +100,000 VND\nND: TEST\nSo du: 9,900,000 VND'),
    );

    expect(result!.balanceAfter, 9900000);
  });

  test('nội dung tiếng Việt có dấu được giữ nguyên', () {
    final result = parser.parse(
      notif(text: 'TK ****1234 +200,000 VND\nND: NGUYỄN VĂN Ạ CHUYỂN TIỀN MỪNG TUỔI'),
    );

    expect(result!.description, 'NGUYỄN VĂN Ạ CHUYỂN TIỀN MỪNG TUỔI');
  });

  test('notification bị dồn về một dòng (không xuống dòng) vẫn parse đúng', () {
    final result = parser.parse(
      notif(text: 'TK ****1234 +2,000,000 VND ND: NGUYEN VAN A CHUYEN TIEN SD: 15,500,000 VND'),
    );

    expect(result, isNotNull);
    expect(result!.amount, 2000000);
    expect(result.description, 'NGUYEN VAN A CHUYEN TIEN');
    expect(result.balanceAfter, 15500000);
  });

  test('không có dấu +/- nhưng có từ khoá "ghi co" vẫn suy ra được income', () {
    final result = parser.parse(
      notif(text: 'TK ****1234 Ghi co 300,000 VND\nND: NHAN LUONG'),
    );

    expect(result!.type, TransactionType.income);
  });

  test('trích xuất được mã giao dịch khi có', () {
    final result = parser.parse(
      notif(text: 'TK ****1234 +100,000 VND\nND: TEST\nMa GD: FT26224001122'),
    );

    expect(result!.transactionCode, 'FT26224001122');
  });

  test('rawNotification lưu lại toàn bộ nội dung gốc để debug', () {
    const text = 'TK ****1234 +100,000 VND\nND: TEST';
    final result = parser.parse(notif(text: text));

    expect(result!.rawNotification, contains(text));
    expect(result.sourcePackage, 'com.vietinbank.ipay');
  });
}
