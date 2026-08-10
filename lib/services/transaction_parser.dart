import '../models/notification_data.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import 'parsing/amount_parser.dart';
import 'parsing/transaction_patterns.dart' as patterns;

/// Phân tích [NotificationData] thô thành [Transaction] có cấu trúc.
///
/// Nguyên tắc thiết kế:
/// - KHÔNG bao giờ throw ra ngoài. Notification dị hình, thiếu trường, hay
///   không phải giao dịch đều phải trả về null thay vì làm crash luồng xử lý
///   ở tầng gọi (native EventChannel handler, background sync...).
/// - KHÔNG đoán mò khi thiếu dữ kiện quan trọng: nếu không xác định được số
///   tiền hoặc loại giao dịch (income/expense), trả về null thay vì tạo ra
///   một giao dịch với dữ liệu sai.
/// - Mỗi trường được thử qua một DANH SÁCH pattern (xem
///   parsing/transaction_patterns.dart) theo thứ tự ưu tiên. Muốn hỗ trợ
///   thêm định dạng notification mới, chỉ cần thêm RegExp vào đúng danh sách
///   — không cần sửa class này.
class TransactionParser {
  const TransactionParser();

  Transaction? parse(NotificationData notification) {
    try {
      return _parseInternal(notification);
    } catch (_) {
      return null;
    }
  }

  Transaction? _parseInternal(NotificationData notification) {
    final content = notification.fullContent;
    if (content.trim().isEmpty) return null;

    final amountMatch = _matchAmount(content);
    if (amountMatch == null) return null;

    final type = amountMatch.type ?? _inferTypeFromKeywords(content);
    if (type == null) return null;

    final account = _matchFirst(content, patterns.accountPatterns);
    final description = _matchDescription(content) ?? '';
    final balanceRaw = _matchFirst(content, patterns.balancePatterns);
    final balanceAfter = balanceRaw != null ? AmountParser.parse(balanceRaw) : null;
    final transactionCode = _matchFirst(content, patterns.transactionCodePatterns);
    final transactionTime = _matchDateTime(content) ?? notification.postTime;

    return Transaction(
      type: type,
      amount: amountMatch.amount,
      currency: amountMatch.currency ?? 'VND',
      account: account,
      description: description,
      balanceAfter: balanceAfter,
      transactionTime: transactionTime,
      transactionCode: transactionCode,
      rawNotification: content,
      sourcePackage: notification.packageName,
    );
  }

  _AmountMatch? _matchAmount(String content) {
    for (final pattern in patterns.amountSignPatterns) {
      final match = pattern.firstMatch(content);
      if (match == null) continue;

      final amountRaw = _namedGroupOrNull(match, 'amount');
      if (amountRaw == null) continue;

      final amount = AmountParser.parse(amountRaw);
      if (amount == null) continue;

      final sign = _namedGroupOrNull(match, 'sign');

      return _AmountMatch(
        amount: amount,
        type: sign == '+'
            ? TransactionType.income
            : (sign == '-' ? TransactionType.expense : null),
        currency: _normalizeCurrency(_namedGroupOrNull(match, 'currency')),
      );
    }
    return null;
  }

  /// Đọc named group một cách an toàn: một số pattern trong danh sách không
  /// khai báo hết mọi named group (ví dụ pattern không có currency), gọi
  /// [RegExpMatch.namedGroup] trực tiếp trên group không tồn tại sẽ throw.
  String? _namedGroupOrNull(RegExpMatch match, String name) {
    if (!match.groupNames.contains(name)) return null;
    return match.namedGroup(name);
  }

  TransactionType? _inferTypeFromKeywords(String content) {
    final normalized = _stripDiacritics(content.toLowerCase());
    for (final keyword in patterns.incomeKeywords) {
      if (normalized.contains(keyword)) return TransactionType.income;
    }
    for (final keyword in patterns.expenseKeywords) {
      if (normalized.contains(keyword)) return TransactionType.expense;
    }
    return null;
  }

  String? _matchFirst(String content, List<RegExp> candidates) {
    for (final pattern in candidates) {
      final value = pattern.firstMatch(content)?.group(1)?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _matchDescription(String content) {
    for (final pattern in patterns.descriptionPatterns) {
      final raw = pattern.firstMatch(content)?.group(1)?.trim();
      if (raw == null || raw.isEmpty) continue;

      final trimmed = _stopAtNextLabel(raw);
      if (trimmed.isNotEmpty) return _stripReferenceCodePrefix(trimmed);
    }
    return null;
  }

  String _stopAtNextLabel(String captured) {
    final stopMatch = patterns.nextLabelPattern.firstMatch(captured);
    if (stopMatch == null) return captured.trim();
    return captured.substring(0, stopMatch.start).trim();
  }

  /// Một số bank (VietinBank QR) nhúng mã tham chiếu ngay trong nội dung,
  /// dạng `<mã> QR - <nội dung thật>`. Bóc phần mã ra nếu khớp; giữ nguyên
  /// description gốc nếu không khớp pattern nào (không ép buộc).
  String _stripReferenceCodePrefix(String description) {
    for (final pattern in patterns.descriptionPrefixStripPatterns) {
      final cleaned = pattern.firstMatch(description)?.group(1)?.trim();
      if (cleaned != null && cleaned.isNotEmpty) return cleaned;
    }
    return description;
  }

  DateTime? _matchDateTime(String content) {
    for (final pattern in patterns.dateTimePatterns) {
      final match = pattern.firstMatch(content);
      if (match == null) continue;

      final day = int.tryParse(match.group(1) ?? '');
      final month = int.tryParse(match.group(2) ?? '');
      final year = int.tryParse(match.group(3) ?? '');
      final hour = int.tryParse(match.group(4) ?? '');
      final minute = int.tryParse(match.group(5) ?? '');
      final second = int.tryParse(match.group(6) ?? '') ?? 0;

      if (day == null || month == null || year == null || hour == null || minute == null) {
        continue;
      }
      if (month < 1 || month > 12 || day < 1 || day > 31) continue;

      return DateTime(year, month, day, hour, minute, second);
    }
    return null;
  }

  String? _normalizeCurrency(String? raw) {
    if (raw == null) return null;
    if (raw == '₫') return 'VND';
    final upper = raw.toUpperCase();
    if (upper == 'VNĐ' || upper == 'Đ') return 'VND';
    return upper;
  }

  static const _withDiacritics =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  static const _withoutDiacritics =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

  String _stripDiacritics(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final index = _withDiacritics.indexOf(char);
      buffer.write(index == -1 ? char : _withoutDiacritics[index]);
    }
    return buffer.toString();
  }
}

class _AmountMatch {
  const _AmountMatch({required this.amount, required this.type, required this.currency});

  final int amount;
  final TransactionType? type;
  final String? currency;
}
