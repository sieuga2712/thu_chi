import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/transactions/presentation/screens/manual_transaction_entry_screen.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: ManualTransactionEntryScreen()),
    );
  }

  // Kèm dòng ngày giờ tường minh (dateTimePatterns) để transactionTime cố
  // định, không phụ thuộc DateTime.now() tại thời điểm bấm "Phân tích" —
  // cần thiết để test trùng lặp so khớp đúng fingerprint với bản ghi có sẵn.
  const validContent =
      'TK 104878432165 -35,000 VND\n'
      'ND: NGUYEN MINH QUANG Chuyen tien; tai iPay\n'
      'SD: 15,500,000 VND\n'
      '10/08/2026 08:24:00';
  final validContentTime = DateTime(2026, 8, 10, 8, 24, 0);

  testWidgets('nút Phân tích bị vô hiệu khi ô trống', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('dán nội dung hợp lệ, phân tích ra đúng preview rồi thêm thành công', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('manual_entry_field')), validContent);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Phân tích'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();

    expect(find.text('Xem trước'), findsOneWidget);
    // Nội dung xuất hiện cả trong ô nhập gốc lẫn trong preview — chỉ cần
    // xác nhận preview đọc đúng, không cần độc quyền.
    expect(find.textContaining('NGUYEN MINH QUANG'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Thêm giao dịch'));
    await tester.pumpAndSettle();

    final repo = DriftTransactionRepository(db);
    final all = await repo.getTransactions();
    expect(all, hasLength(1));
    expect(all.single.amount, 35000);
    expect(all.single.type, TransactionType.expense);
    expect(all.single.sourcePackage, 'manual');

    expect(find.text('Đã thêm giao dịch'), findsOneWidget);
    // Form được reset để dán tiếp giao dịch khác.
    expect(find.text('Xem trước'), findsNothing);
  });

  testWidgets('dán nội dung không đọc được báo lỗi rõ ràng, không có preview', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('manual_entry_field')),
      'Ưu đãi tháng 8 dành cho bạn',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Phân tích'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();

    expect(find.textContaining('Không đọc được giao dịch'), findsOneWidget);
    expect(find.text('Xem trước'), findsNothing);
  });

  testWidgets('dán nội dung trùng giao dịch đã có báo trùng, không thêm bản ghi mới', (tester) async {
    final repo = DriftTransactionRepository(db);
    await repo.insert(
      Transaction(
        type: TransactionType.expense,
        amount: 35000,
        currency: 'VND',
        account: '104878432165',
        description: 'NGUYEN MINH QUANG Chuyen tien; tai iPay',
        balanceAfter: 15500000,
        transactionTime: validContentTime,
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('manual_entry_field')), validContent);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Phân tích'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Thêm giao dịch'));
    await tester.pumpAndSettle();

    final all = await repo.getTransactions();
    expect(all, hasLength(1));
    expect(find.textContaining('trùng với giao dịch đã có'), findsOneWidget);
  });

  testWidgets('bấm Sửa lại quay về trạng thái nhập, xóa preview', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('manual_entry_field')), validContent);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Phân tích'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();

    expect(find.text('Xem trước'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sửa lại'));
    await tester.pumpAndSettle();

    expect(find.text('Xem trước'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Phân tích'), findsOneWidget);
  });
}
