import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/settings/presentation/screens/category_management_screen.dart';
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
      child: const MaterialApp(home: CategoryManagementScreen()),
    );
  }

  testWidgets('hiển thị đủ preset + tag tự gõ đã dùng, không trùng lặp', (tester) async {
    final repo = DriftTransactionRepository(db);
    await repo.insert(
      Transaction(
        type: TransactionType.expense,
        amount: 10000,
        currency: 'VND',
        description: 'test',
        transactionTime: DateTime(2026, 1, 1),
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );
    // category chỉ được gán qua updateCategory sau khi đã insert (giống cách
    // màn hình chi tiết thật sự dùng) — insert() không nhận category ban đầu.
    final inserted = (await repo.getTransactions()).single;
    await repo.updateCategory(inserted.id!, 'Tag lạ tự gõ');

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Ăn vặt'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();
    expect(find.text('Tag lạ tự gõ'), findsOneWidget);
  });

  testWidgets('xóa tag: gỡ khỏi giao dịch đang dùng, biến mất khỏi danh sách', (tester) async {
    final repo = DriftTransactionRepository(db);
    await repo.insert(
      Transaction(
        type: TransactionType.expense,
        amount: 10000,
        currency: 'VND',
        description: 'test',
        transactionTime: DateTime(2026, 1, 1),
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );
    final inserted = (await repo.getTransactions()).single;
    await repo.updateCategory(inserted.id!, 'Ăn vặt');

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Ăn vặt'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.ancestor(of: find.text('Ăn vặt'), matching: find.byType(ListTile)),
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Ăn vặt'), findsNothing);
    expect(find.textContaining('Đã xóa tag'), findsOneWidget);

    final updated = await repo.getById(inserted.id!);
    expect(updated!.category, '');
  });

  testWidgets('tag đã xóa không xuất hiện lại kể cả sau khi tạo lại màn hình', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.ancestor(of: find.text('Giải trí'), matching: find.byType(ListTile)),
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Giải trí'), findsNothing);

    // Dựng lại toàn bộ widget (giả lập mở lại màn hình) — tag vẫn phải bị ẩn.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Giải trí'), findsNothing);
  });
}
