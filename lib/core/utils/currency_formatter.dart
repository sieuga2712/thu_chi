import 'package:intl/intl.dart';

/// Định dạng số tiền theo đúng kiểu hiển thị trong spec: phân cách hàng nghìn
/// bằng dấu phẩy, ký hiệu tiền tệ ở cuối (ví dụ "25,500,000 ₫").
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _number = NumberFormat('#,##0', 'en_US');

  static String _symbolFor(String currency) => currency == 'VND' ? '₫' : currency;

  static String format(int amount, {String currency = 'VND'}) {
    return '${_number.format(amount)} ${_symbolFor(currency)}';
  }

  /// Có dấu +/- phía trước — dùng cho danh sách/chi tiết giao dịch, nơi cần
  /// phân biệt trực quan tiền vào (xanh, +) và tiền ra (đỏ, -).
  static String formatSigned(int amount, {required bool isIncome, String currency = 'VND'}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(amount, currency: currency)}';
  }
}
