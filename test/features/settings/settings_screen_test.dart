import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/settings/presentation/screens/settings_screen.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/providers/notification_providers.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

import '../../helpers/fake_native_notification_service.dart';

void main() {
  late AppDatabase db;
  late FakeNativeNotificationService fakeService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeService = FakeNativeNotificationService();
  });

  tearDown(() async => db.close());

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        nativeNotificationServiceProvider.overrideWithValue(fakeService),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  testWidgets('chưa cấp quyền hiển thị cảnh báo + nút Cấp quyền', (tester) async {
    fakeService.grantedOverride = false;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Chưa cấp quyền đọc thông báo'), findsOneWidget);
    expect(find.text('Cấp quyền'), findsOneWidget);

    await tester.tap(find.text('Cấp quyền'));
    await tester.pumpAndSettle();

    expect(fakeService.openSettingsCallCount, 1);
  });

  testWidgets('đã cấp quyền hiển thị trạng thái đang theo dõi', (tester) async {
    fakeService.grantedOverride = true;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Đang theo dõi thông báo'), findsOneWidget);
    expect(find.text('Chưa cấp quyền đọc thông báo'), findsNothing);
  });

  testWidgets('bấm gửi thông báo thử nghiệm gọi đúng vào native service', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gửi thông báo thử nghiệm'));
    await tester.pumpAndSettle();

    expect(fakeService.sendTestNotificationCallCount, 1);
    expect(find.textContaining('Đã gửi thông báo thử nghiệm'), findsOneWidget);
  });

  testWidgets('xóa toàn bộ dữ liệu xóa sạch DB sau khi xác nhận', (tester) async {
    final repo = DriftTransactionRepository(db);
    await repo.insert(
      Transaction(
        type: TransactionType.income,
        amount: 1000,
        currency: 'VND',
        description: 'test',
        transactionTime: DateTime(2026, 1, 1),
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );
    expect(await repo.getTransactions(), hasLength(1));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xóa toàn bộ dữ liệu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa tất cả'));
    await tester.pumpAndSettle();

    expect(await repo.getTransactions(), isEmpty);
    expect(find.text('Đã xóa toàn bộ dữ liệu'), findsOneWidget);
  });

  testWidgets('mở dialog giới thiệu app', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Mục "Giới thiệu" nằm cuối danh sách, cần cuộn tới vì ListView chỉ
    // build các item đang hiển thị trong khung hình test.
    await tester.dragUntilVisible(
      find.textContaining('Giới thiệu'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.textContaining('Giới thiệu'));
    await tester.pumpAndSettle();

    expect(find.textContaining('không gửi bất kỳ dữ liệu giao dịch nào lên server'), findsOneWidget);
  });
}
