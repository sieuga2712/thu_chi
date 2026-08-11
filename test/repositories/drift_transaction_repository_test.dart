import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/core/database/app_database.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/repositories/drift_transaction_repository.dart';

void main() {
  late AppDatabase db;
  late DriftTransactionRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTransactionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Transaction sample({
    TransactionType type = TransactionType.income,
    int amount = 2000000,
    DateTime? time,
  }) {
    return Transaction(
      type: type,
      amount: amount,
      currency: 'VND',
      account: '****1234',
      description: 'NGUYEN VAN A CHUYEN TIEN',
      balanceAfter: 15500000,
      transactionTime: time ?? DateTime(2026, 8, 10, 8, 30),
      transactionCode: 'FT26224001',
      rawNotification: 'TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A CHUYEN TIEN\nSD: 15,500,000 VND',
      sourcePackage: 'com.vietinbank.ipay',
    );
  }

  test('insert rồi getTransactions trả về đúng giao dịch vừa lưu', () async {
    await repository.insert(sample());

    final all = await repository.getTransactions();

    expect(all, hasLength(1));
    expect(all.first.amount, 2000000);
    expect(all.first.type, TransactionType.income);
    expect(all.first.description, 'NGUYEN VAN A CHUYEN TIEN');
    expect(all.first.id, isNotNull);
  });

  test('getById trả về đúng giao dịch theo id, null nếu không tồn tại', () async {
    await repository.insert(sample());
    final inserted = (await repository.getTransactions()).first;

    final found = await repository.getById(inserted.id!);
    final notFound = await repository.getById(999999);

    expect(found, isNotNull);
    expect(found!.id, inserted.id);
    expect(notFound, isNull);
  });

  test('getTransactions sắp xếp theo thời gian giao dịch giảm dần', () async {
    await repository.insert(sample(time: DateTime(2026, 8, 1)));
    await repository.insert(sample(time: DateTime(2026, 8, 10)));
    await repository.insert(sample(time: DateTime(2026, 8, 5)));

    final all = await repository.getTransactions();

    expect(all.map((t) => t.transactionTime.day).toList(), [10, 5, 1]);
  });

  test('delete xóa đúng một giao dịch theo id', () async {
    await repository.insert(sample());
    await repository.insert(sample(amount: 350000, type: TransactionType.expense));
    final all = await repository.getTransactions();
    final idToDelete = all.first.id!;

    await repository.delete(idToDelete);
    final remaining = await repository.getTransactions();

    expect(remaining, hasLength(1));
    expect(remaining.any((t) => t.id == idToDelete), isFalse);
  });

  test('deleteAll xóa sạch toàn bộ giao dịch', () async {
    await repository.insert(sample());
    await repository.insert(sample());
    await repository.insert(sample());

    await repository.deleteAll();
    final all = await repository.getTransactions();

    expect(all, isEmpty);
  });

  test('lưu và đọc lại đúng transactionCode và rawNotification (phục vụ debug parser)', () async {
    await repository.insert(sample());
    final all = await repository.getTransactions();

    expect(all.first.transactionCode, 'FT26224001');
    expect(all.first.rawNotification, contains('NGUYEN VAN A CHUYEN TIEN'));
    expect(all.first.sourcePackage, 'com.vietinbank.ipay');
  });

  group('Phase 11 - ghi chú cá nhân', () {
    test('giao dịch mới insert có note rỗng mặc định', () async {
      await repository.insert(sample());
      final all = await repository.getTransactions();

      expect(all.single.note, '');
    });

    test('updateNote cập nhật đúng note, không đụng các trường khác', () async {
      await repository.insert(sample());
      final inserted = (await repository.getTransactions()).single;

      await repository.updateNote(inserted.id!, 'Tiền ăn trưa với đồng nghiệp');
      final updated = await repository.getById(inserted.id!);

      expect(updated!.note, 'Tiền ăn trưa với đồng nghiệp');
      expect(updated.amount, inserted.amount);
      expect(updated.description, inserted.description);
    });

    test('updateNote với id không tồn tại không crash', () async {
      await expectLater(repository.updateNote(999999, 'ghi chú'), completes);
    });
  });

  group('Nhóm chi tiêu (category)', () {
    test('giao dịch mới insert có category rỗng mặc định', () async {
      await repository.insert(sample());
      final all = await repository.getTransactions();

      expect(all.single.category, '');
    });

    test('updateCategory cập nhật đúng category, không đụng các trường khác', () async {
      await repository.insert(sample());
      final inserted = (await repository.getTransactions()).single;

      await repository.updateCategory(inserted.id!, 'Xăng xe');
      final updated = await repository.getById(inserted.id!);

      expect(updated!.category, 'Xăng xe');
      expect(updated.amount, inserted.amount);
      expect(updated.note, inserted.note);
    });

    test('updateCategory với id không tồn tại không crash', () async {
      await expectLater(repository.updateCategory(999999, 'nhóm'), completes);
    });

    test('getDistinctCategories trả về danh sách không trùng, đã sắp xếp, bỏ qua rỗng', () async {
      await repository.insert(sample(time: DateTime(2026, 8, 1)));
      await repository.insert(sample(time: DateTime(2026, 8, 2)));
      await repository.insert(sample(time: DateTime(2026, 8, 3)));
      final all = await repository.getTransactions();

      await repository.updateCategory(all[0].id!, 'Xăng xe');
      await repository.updateCategory(all[1].id!, 'Ăn vặt');
      await repository.updateCategory(all[2].id!, 'Xăng xe');

      final categories = await repository.getDistinctCategories();

      expect(categories, ['Xăng xe', 'Ăn vặt']..sort());
    });
  });

  group('Phase 9 - chống trùng lặp (fingerprint)', () {
    test('insert cùng một giao dịch hai lần chỉ lưu một bản ghi', () async {
      await repository.insert(sample());
      await repository.insert(sample());

      final all = await repository.getTransactions();

      expect(all, hasLength(1));
    });

    test('insert cùng dữ liệu nhưng khác rawNotification/notificationKey vẫn coi là trùng', () async {
      // Mô phỏng trường hợp service native gửi lại cùng một giao dịch với
      // key khác nhau — fingerprint chỉ dựa trên bản chất giao dịch, không
      // dựa trên rawNotification, nên vẫn phải bị coi là trùng.
      await repository.insert(sample());
      final duplicateWithDifferentRaw = Transaction(
        type: TransactionType.income,
        amount: 2000000,
        currency: 'VND',
        account: '****1234',
        description: 'NGUYEN VAN A CHUYEN TIEN',
        balanceAfter: 15500000,
        transactionTime: DateTime(2026, 8, 10, 8, 30),
        transactionCode: 'FT26224001',
        rawNotification: 'Nội dung notification khác hoàn toàn do bị gửi lại',
        sourcePackage: 'com.vietinbank.ipay',
      );

      await repository.insert(duplicateWithDifferentRaw);
      final all = await repository.getTransactions();

      expect(all, hasLength(1));
    });

    test('giao dịch khác amount không bị coi là trùng, vẫn lưu cả hai', () async {
      await repository.insert(sample(amount: 2000000));
      await repository.insert(sample(amount: 2000001));

      final all = await repository.getTransactions();

      expect(all, hasLength(2));
    });

    test('giao dịch khác thời gian không bị coi là trùng, vẫn lưu cả hai', () async {
      await repository.insert(sample(time: DateTime(2026, 8, 10, 8, 30)));
      await repository.insert(sample(time: DateTime(2026, 8, 10, 9, 0)));

      final all = await repository.getTransactions();

      expect(all, hasLength(2));
    });

    test('sau khi bị bỏ qua do trùng, giao dịch gốc vẫn còn nguyên và đọc lại đúng', () async {
      await repository.insert(sample());
      await repository.insert(sample());

      final all = await repository.getTransactions();

      expect(all.single.amount, 2000000);
      expect(all.single.description, 'NGUYEN VAN A CHUYEN TIEN');
    });
  });
}
