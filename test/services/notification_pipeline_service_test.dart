import 'package:flutter_test/flutter_test.dart';
import 'package:thu_chi/models/notification_data.dart';
import 'package:thu_chi/models/transaction.dart';
import 'package:thu_chi/models/transaction_type.dart';
import 'package:thu_chi/repositories/transaction_repository.dart';
import 'package:thu_chi/services/notification_pipeline_service.dart';

class _FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> saved = [];

  @override
  Future<void> insert(Transaction transaction) async {
    saved.add(transaction);
  }

  @override
  Future<List<Transaction>> getTransactions() async => List.unmodifiable(saved);

  @override
  Future<Transaction?> getById(int id) async => null;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> deleteAll() async => saved.clear();

  @override
  Future<void> updateNote(int id, String note) async {
    final index = saved.indexWhere((t) => t.id == id);
    if (index != -1) saved[index] = saved[index].copyWith(note: note);
  }

  @override
  Future<void> updateCategory(int id, String category) async {
    final index = saved.indexWhere((t) => t.id == id);
    if (index != -1) saved[index] = saved[index].copyWith(category: category);
  }

  @override
  Future<List<String>> getDistinctCategories() async {
    return saved.map((t) => t.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
  }
}

void main() {
  late _FakeTransactionRepository repository;
  late NotificationPipelineService pipeline;

  setUp(() {
    repository = _FakeTransactionRepository();
    pipeline = NotificationPipelineService(repository: repository);
  });

  NotificationData notif(String text) {
    final now = DateTime(2026, 8, 10, 8, 30);
    return NotificationData(
      packageName: 'com.vietinbank.ipay',
      title: 'VietinBank',
      text: text,
      bigText: text,
      subText: null,
      postTime: now,
      capturedAt: now,
      notificationKey: 'key',
    );
  }

  test('process() parse thành công thì lưu vào repository và trả về transaction', () async {
    final result = await pipeline.process(
      notif('TK ****1234 +2,000,000 VND\nND: NGUYEN VAN A CHUYEN TIEN\nSD: 15,500,000 VND'),
    );

    expect(result, isNotNull);
    expect(result!.type, TransactionType.income);
    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.amount, 2000000);
  });

  test('process() không parse được thì không lưu gì, trả về null', () async {
    final result = await pipeline.process(notif('Ưu đãi tháng 8 dành cho bạn'));

    expect(result, isNull);
    expect(repository.saved, isEmpty);
  });

  test('processAll() chỉ lưu những notification parse thành công, trả về đúng số lượng', () async {
    final count = await pipeline.processAll([
      notif('TK ****1234 +2,000,000 VND\nND: A'),
      notif('Ưu đãi không liên quan giao dịch'),
      notif('TK ****1234 -350,000 VND\nND: B'),
    ]);

    expect(count, 2);
    expect(repository.saved, hasLength(2));
  });

  test('processAll() với danh sách rỗng không lưu gì, không crash', () async {
    final count = await pipeline.processAll(const []);

    expect(count, 0);
    expect(repository.saved, isEmpty);
  });
}
