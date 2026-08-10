import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/providers/database_providers.dart';
import 'package:thu_chi/providers/supabase_providers.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

import '../../helpers/fake_note_sync_service.dart';

void main() {
  late AppDatabase db;
  late FakeNoteSyncService fakeNoteSync;
  late Transaction insertedTransaction;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeNoteSync = FakeNoteSyncService();

    final repo = DriftTransactionRepository(db);
    await repo.insert(
      Transaction(
        type: TransactionType.income,
        amount: 2000000,
        currency: 'VND',
        account: '****1234',
        description: 'NGUYEN VAN A CHUYEN TIEN',
        balanceAfter: 15500000,
        transactionTime: DateTime(2026, 8, 10, 8, 30),
        rawNotification: 'raw',
        sourcePackage: 'com.vietinbank.ipay',
      ),
    );
    insertedTransaction = (await repo.getTransactions()).single;
  });

  tearDown(() async => db.close());

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        noteSyncServiceProvider.overrideWithValue(fakeNoteSync),
      ],
      child: MaterialApp(home: TransactionDetailScreen(transaction: insertedTransaction)),
    );
  }

  testWidgets('nút Lưu ghi chú bị vô hiệu khi chưa sửa gì', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('sửa ghi chú rồi lưu: cập nhật DB local và đẩy lên sync service', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Tiền lì xì đầu năm');
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);

    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final repo = DriftTransactionRepository(db);
    final updated = await repo.getById(insertedTransaction.id!);
    expect(updated!.note, 'Tiền lì xì đầu năm');

    expect(fakeNoteSync.pushedNotes, hasLength(1));
    expect(fakeNoteSync.pushedNotes.single.note, 'Tiền lì xì đầu năm');
    expect(find.textContaining('Đã lưu ghi chú và đồng bộ'), findsOneWidget);
  });

  testWidgets('đồng bộ Supabase thất bại vẫn giữ nguyên note đã lưu local', (tester) async {
    fakeNoteSync.pushError = Exception('network error');

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ghi chú offline');
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final repo = DriftTransactionRepository(db);
    final updated = await repo.getById(insertedTransaction.id!);
    expect(updated!.note, 'Ghi chú offline');
    expect(find.textContaining('đồng bộ Supabase thất bại'), findsOneWidget);
  });
}
