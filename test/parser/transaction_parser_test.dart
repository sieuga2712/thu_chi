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

  test(
    'notification format thay đổi (thứ tự nhãn khác, không có TK) vẫn parse đúng '
    'nhờ hệ thống pattern linh hoạt, không cần sửa code',
    () {
      // Định dạng giả định khác hẳn 2 ví dụ chuẩn trong spec: đảo thứ tự
      // Số dư trước Nội dung, không có nhãn "TK", cách diễn đạt khác
      // ("Biến động" thay vì đứng ngay sau số tài khoản).
      final result = parser.parse(
        notif(
          text: 'VietinBank Smart\nBiến động: -75,000 VND\nSố dư: 3,200,000 VND\nNội dung: THANH TOAN GRAB',
        ),
      );

      expect(result, isNotNull);
      expect(result!.type, TransactionType.expense);
      expect(result.amount, 75000);
      expect(result.balanceAfter, 3200000);
      expect(result.description, 'THANH TOAN GRAB');
      // Không có nhãn TK/Tài khoản trong định dạng giả định này -> không
      // đoán mò, account phải là null thay vì suy diễn sai.
      expect(result.account, isNull);
    },
  );

  test(
    'dữ liệu thật từ VietinBank iPay: bóc mã tham chiếu "<mã> QR - " ra khỏi nội dung, '
    'giữ số tài khoản đầy đủ không che',
    () {
      // Ghi lại nguyên văn từ notification thật bắt được trên thiết bị thật
      // (xem section 6/9 — không có số dư trong loại notification QR này).
      final result = parser.parse(
        notif(
          text:
              'TK 104878432165 -35,000VND\n'
              'ND: CT DI:248K2680F56JXSTT QR - NGUYEN MINH QUANG Chuyen tien; tai iPay',
        ),
      );

      expect(result, isNotNull);
      expect(result!.type, TransactionType.expense);
      expect(result.amount, 35000);
      expect(result.account, '104878432165');
      expect(result.description, 'NGUYEN MINH QUANG Chuyen tien; tai iPay');
      expect(result.balanceAfter, isNull);
    },
  );

  test('nội dung không có "QR -" thì giữ nguyên, không bị cắt xén nhầm', () {
    final result = parser.parse(
      notif(text: 'TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A CHUYEN TIEN'),
    );

    expect(result!.description, 'NGUYEN VAN A CHUYEN TIEN');
  });

  test(
    'duplicate notification: cùng nội dung parse ra cùng dữ liệu giao dịch mỗi lần '
    '(chống trùng lặp thật sự nằm ở tầng repository/fingerprint, xem '
    'test/repositories/drift_transaction_repository_test.dart nhóm "Phase 9")',
    () {
      const text = 'TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A CHUYEN TIEN\nSD: 15,500,000 VND';
      final first = parser.parse(notif(text: text));
      final second = parser.parse(notif(text: text));

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.amount, second!.amount);
      expect(first.description, second.description);
      expect(first.balanceAfter, second.balanceAfter);
      expect(first.transactionTime, second.transactionTime);
    },
  );
}
