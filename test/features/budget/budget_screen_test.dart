import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/budget/presentation/screens/budget_screen.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/providers/category_settings_providers.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async => db.close());

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: BudgetScreen()),
    );
  }

  testWidgets('chưa có ngân sách: hiện form nhập ngay, không có nút Sửa/Xóa', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Đặt hạn mức chi tiêu'), findsOneWidget);
    expect(find.text('Sửa'), findsNothing);
    expect(find.text('Xóa ngân sách'), findsNothing);
  });

  testWidgets('chưa có ngân sách: mặc định chọn kỳ Ngày và hạn mức 200000', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byKey(const Key('budget_limit_field')));
    expect(field.controller!.text, '200000');

    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ngân sách theo ngày'), findsOneWidget);
    expect(find.textContaining('/ 200,000 ₫'), findsOneWidget);
  });

  testWidgets('nhập hạn mức tuần rồi lưu: hiện tiến trình đúng từ giao dịch thật', (tester) async {
    final repo = DriftTransactionRepository(db);
    final now = DateTime.now();
    await repo.insert(
      Transaction(
        type: TransactionType.expense,
        amount: 200000,
        currency: 'VND',
        description: 'test',
        transactionTime: now,
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tuần'));
    await tester.enterText(find.byKey(const Key('budget_limit_field')), '1000000');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Đã chi: 200,000 ₫ / 1,000,000 ₫'), findsOneWidget);
    expect(find.textContaining('Còn lại: 800,000 ₫'), findsOneWidget);
  });

  testWidgets('vượt hạn mức thì hiện "Đã vượt"', (tester) async {
    final repo = DriftTransactionRepository(db);
    await repo.insert(
      Transaction(
        type: TransactionType.expense,
        amount: 1500000,
        currency: 'VND',
        description: 'test',
        transactionTime: DateTime.now(),
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('budget_limit_field')), '1000000');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Đã vượt: 500,000 ₫'), findsOneWidget);
  });

  testWidgets('nhập hạn mức không hợp lệ báo lỗi rõ ràng, không lưu', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Xóa hết giá trị mặc định (200000) để mô phỏng ô nhập rỗng/không hợp lệ.
    await tester.enterText(find.byKey(const Key('budget_limit_field')), '');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nhập hạn mức hợp lệ'), findsOneWidget);
    expect(find.text('Đặt hạn mức chi tiêu'), findsOneWidget);
  });

  testWidgets('xóa ngân sách quay về form nhập', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('budget_limit_field')), '1000000');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xóa ngân sách'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Đặt hạn mức chi tiêu'), findsOneWidget);
  });
}
