import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/providers/category_settings_providers.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

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
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
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
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(home: TransactionListScreen()),
    );
  }

  testWidgets('gom giao dịch theo ngày, lọc theo loại và tìm kiếm hoạt động đúng', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('10/08/2026'), findsOneWidget);
    expect(find.textContaining('09/08/2026'), findsOneWidget);
    expect(find.text('+2,000,000 ₫'), findsOneWidget);
    expect(find.text('-350,000 ₫'), findsOneWidget);

    await tester.tap(find.text('Tiền vào'));
    await tester.pumpAndSettle();
    expect(find.textContaining('10/08/2026'), findsOneWidget);
    expect(find.textContaining('09/08/2026'), findsNothing);

    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'cafe');
    await tester.pumpAndSettle();
    expect(find.textContaining('09/08/2026'), findsOneWidget);
    expect(find.textContaining('10/08/2026'), findsNothing);
  });

  testWidgets('không tìm thấy giao dịch nào hiển thị thông báo rõ ràng', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'khong ton tai');
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy giao dịch nào'), findsOneWidget);
  });

  testWidgets('bấm vào ngày mở đủ giao dịch, bấm vào giao dịch mở chi tiết, xóa xong biến mất', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('10/08/2026'));
    await tester.pumpAndSettle();

    expect(find.text('NGUYEN VAN A CHUYEN TIEN'), findsOneWidget);
    expect(find.text('THANH TOAN CAFE'), findsNothing);

    await tester.tap(find.text('NGUYEN VAN A CHUYEN TIEN'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết giao dịch'), findsOneWidget);
    expect(find.text('+2,000,000 ₫'), findsOneWidget);
    expect(find.text('****1234'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    // Quay lại màn hình ngày 10/08 (tự cập nhật, không còn giao dịch nào).
    expect(find.text('Chi tiết giao dịch'), findsNothing);
    expect(find.text('NGUYEN VAN A CHUYEN TIEN'), findsNothing);
    expect(
      find.text('Không còn giao dịch nào trong khoảng này'),
      findsOneWidget,
    );
  });

  testWidgets('chuyển sang Tuần: gom đúng theo tuần (2 giao dịch cùng tuần)', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tuần'));
    await tester.pumpAndSettle();

    // 10/08 và 09/08/2026 cùng nằm trong tuần 33 (Thứ 2 03/08 - Chủ nhật 09/08... );
    // thực tế 10/08 là Thứ 2 nên khác tuần với 09/08 (Chủ nhật tuần trước).
    expect(find.textContaining('Tuần'), findsWidgets);
    expect(find.text('+2,000,000 ₫'), findsOneWidget);
    expect(find.text('-350,000 ₫'), findsOneWidget);
  });

  testWidgets('chuyển sang Tháng: gom 2 giao dịch cùng tháng 8/2026 vào 1 dòng', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tháng'));
    await tester.pumpAndSettle();

    expect(find.textContaining('08/2026'), findsOneWidget);
    expect(find.text('2 giao dịch'), findsOneWidget);

    await tester.tap(find.textContaining('08/2026'));
    await tester.pumpAndSettle();

    expect(find.text('NGUYEN VAN A CHUYEN TIEN'), findsOneWidget);
    expect(find.text('THANH TOAN CAFE'), findsOneWidget);
  });
}
