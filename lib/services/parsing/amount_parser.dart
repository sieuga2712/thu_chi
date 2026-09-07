/// Phân tích số tiền dạng chuỗi từ notification ngân hàng thành số nguyên VND.
///
/// Xử lý cả hai kiểu phân cách hàng nghìn phổ biến trên notification ngân
/// hàng Việt Nam: dấu phẩy (2,000,000) và dấu chấm (2.000.000). Không dùng
/// một regex "đoán" cứng nhắc mà dùng một heuristic đơn giản, ổn định: dấu
/// phân cách CUỐI CÙNG trong chuỗi chỉ được coi là dấu thập phân nếu theo
/// sau nó là đúng 1-2 chữ số (ví dụ "150.50"); mọi trường hợp còn lại — kể
/// cả khi có nhiều dấu phân cách liên tiếp mỗi nhóm 3 chữ số — đều được coi
/// là phân cách hàng nghìn và bị loại bỏ.
class AmountParser {
  AmountParser._();

  /// Trả về null nếu [raw] không chứa số nào hợp lệ. Không bao giờ throw.
  static int? parse(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    // Chỉ giữ lại chữ số, dấu chấm và dấu phẩy — bỏ "VND", "đ", khoảng trắng...
    final numericOnly = cleaned.replaceAll(RegExp(r'[^\d.,]'), '');
    if (numericOnly.isEmpty) return null;

    final lastDot = numericOnly.lastIndexOf('.');
    final lastComma = numericOnly.lastIndexOf(',');
    final lastSeparatorIndex = lastDot > lastComma ? lastDot : lastComma;

    if (lastSeparatorIndex == -1) {
      return int.tryParse(numericOnly);
    }

    final fractionDigits = numericOnly.length - lastSeparatorIndex - 1;
    final looksLikeDecimalSeparator =
        fractionDigits == 1 || fractionDigits == 2;

    final integerPartRaw = looksLikeDecimalSeparator
        ? numericOnly.substring(0, lastSeparatorIndex)
        : numericOnly;

    final digitsOnly = integerPartRaw.replaceAll(RegExp(r'[.,]'), '');
    if (digitsOnly.isEmpty) return null;
    return int.tryParse(digitsOnly);
  }
}
