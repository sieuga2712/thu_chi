import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

void main() {
  late AppDatabase db;

  Transaction tx({
    required TransactionType type,
    required int amount,
    required String description,
    DateTime? time,
  }) {
    return Transaction(
      type: type,
      amount: amount,
      currency: 'VND',
      account: '****1234',
      description: description,
      balanceAfter: 15500000,
      transactionTime: time ?? DateTime(2026, 8, 10, 8, 30),
      rawNotification: 'raw',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = DriftTransactionRepository(db);
    await repo.insert(
      tx(type: TransactionType.income, amount: 2000000, description: 'NGUYEN VAN A CHUYEN TIEN'),
    );
    await repo.insert(
      tx(
        type: TransactionType.expense,
        amount: 350000,
        description: 'THANH TOAN CAFE',
        time: DateTime(2026, 8, 9),
      ),
    );
  });

  tearDown(() async => db.close());

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: TransactionListScreen()),
    );
  }

  testWidgets('hiển thị danh sách, lọc theo loại và tìm kiếm hoạt động đúng', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('NGUYEN VAN A CHUYEN TIEN'), findsOneWidget);
    expect(find.text('THANH TOAN CAFE'), findsOneWidget);

    await tester.tap(find.text('Tiền vào'));
    await tester.pumpAndSettle();
    expect(find.text('NGUYEN VAN A CHUYEN TIEN'), findsOneWidget);
    expect(find.text('THANH TOAN CAFE'), findsNothing);

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'cafe');
    await tester.pumpAndSettle();
    expect(find.text('THANH TOAN CAFE'), findsOneWidget);
    expect(find.text('NGUYEN VAN A CHUYEN TIEN'), findsNothing);
  });

  testWidgets('không tìm thấy giao dịch nào hiển thị thông báo rõ ràng', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'khong ton tai');
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy giao dịch nào'), findsOneWidget);
  });

  testWidgets('bấm vào giao dịch mở chi tiết, xóa xong quay lại danh sách và mất khỏi list', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('NGUYEN VAN A CHUYEN TIEN'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết giao dịch'), findsOneWidget);
    expect(find.text('+2,000,000 ₫'), findsOneWidget);
    expect(find.text('****1234'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết giao dịch'), findsNothing);
    expect(find.text('NGUYEN VAN A CHUYEN TIEN'), findsNothing);
    expect(find.text('THANH TOAN CAFE'), findsOneWidget);
  });
}
