import '../models/notification_data.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import 'transaction_parser.dart';

/// Nối [TransactionParser] với [TransactionRepository]: nhận một
/// [NotificationData] thô, parse thành [Transaction], rồi lưu vào DB.
///
/// Đây là điểm DUY NHẤT trong app gọi parser rồi insert — cả luồng backlog
/// (native đệm sẵn) lẫn luồng live (EventChannel) đều đi qua class này, để
/// logic không bị lặp ở hai nơi.
class NotificationPipelineService {
  NotificationPipelineService({required TransactionRepository repository, TransactionParser? parser})
    : _repository = repository,
      _parser = parser ?? const TransactionParser();

  final TransactionRepository _repository;
  final TransactionParser _parser;

  /// Parse + lưu một notification. Trả về null nếu không parse được (không
  /// phải giao dịch, format lạ...) — không throw.
  Future<Transaction?> process(NotificationData notification) async {
    final transaction = _parser.parse(notification);
    if (transaction == null) return null;

    await _repository.insert(transaction);
    return transaction;
  }

  /// Xử lý hàng loạt (dùng cho backlog lúc app khởi động). Trả về số lượng
  /// giao dịch parse + lưu thành công.
  Future<int> processAll(List<NotificationData> notifications) async {
    var savedCount = 0;
    for (final notification in notifications) {
      final result = await process(notification);
      if (result != null) savedCount++;
    }
    return savedCount;
  }
}
