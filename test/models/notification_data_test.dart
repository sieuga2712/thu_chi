import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/models/notification_data.dart';

void main() {
  group('NotificationData.fromMap', () {
    test('map đầy đủ trường từ native', () {
      final data = NotificationData.fromMap({
        'packageName': 'com.vietinbank.ipay',
        'title': 'VietinBank',
        'text': 'TK ****1234 +2,000,000 VND',
        'bigText': 'TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A\nSD: 15,500,000 VND',
        'subText': null,
        'postTimeEpochMillis': 1754800000000,
        'capturedAtEpochMillis': 1754800000500,
        'notificationKey': '0|com.vietinbank.ipay|123|null|10001',
      });

      expect(data.packageName, 'com.vietinbank.ipay');
      expect(data.title, 'VietinBank');
      expect(data.bigText, contains('SD: 15,500,000 VND'));
      expect(data.subText, isNull);
      expect(data.postTime, DateTime.fromMillisecondsSinceEpoch(1754800000000));
      expect(data.notificationKey, isNotEmpty);
    });

    test('map thiếu trường không crash, dùng giá trị mặc định', () {
      final data = NotificationData.fromMap(const {});

      expect(data.packageName, '');
      expect(data.title, '');
      expect(data.text, '');
      expect(data.bigText, isNull);
      expect(data.notificationKey, '');
    });
  });

  group('NotificationData.fullContent', () {
    test('ưu tiên bigText khi có, kèm title', () {
      final data = NotificationData(
        packageName: 'com.vietinbank.ipay',
        title: 'VietinBank',
        text: 'text ngắn',
        bigText: 'ND: NGUYEN VAN A CHUYEN TIEN\nSD: 15,500,000 VND',
        subText: null,
        postTime: DateTime(2026, 8, 10, 8, 30),
        capturedAt: DateTime(2026, 8, 10, 8, 30, 1),
        notificationKey: 'k1',
      );

      expect(data.fullContent, contains('VietinBank'));
      expect(data.fullContent, contains('SD: 15,500,000 VND'));
      expect(data.fullContent, isNot(contains('text ngắn')));
    });

    test('fallback về text khi không có bigText', () {
      final data = NotificationData(
        packageName: 'com.vietinbank.ipay',
        title: 'VietinBank',
        text: 'TK ****1234 -350,000 VND',
        bigText: null,
        subText: null,
        postTime: DateTime(2026, 8, 10),
        capturedAt: DateTime(2026, 8, 10),
        notificationKey: 'k2',
      );

      expect(data.fullContent, contains('TK ****1234 -350,000 VND'));
    });
  });
}
