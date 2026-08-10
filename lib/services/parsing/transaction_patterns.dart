/// Toàn bộ pattern regex + từ khoá dùng bởi [TransactionParser].
///
/// Mỗi trường (số tiền, tài khoản, nội dung, số dư, mã giao dịch, thời gian)
/// có một DANH SÁCH pattern được thử lần lượt theo thứ tự cho tới khi có
/// pattern khớp. Khi VietinBank (hoặc ngân hàng khác) đổi định dạng
/// notification, chỉ cần thêm một RegExp mới vào đúng danh sách bên dưới —
/// không cần sửa logic trong transaction_parser.dart.
library;

/// Số tiền, kèm dấu +/- nếu có — quyết định cả amount lẫn income/expense.
///
/// Dùng named group (sign/amount/currency) thay vì group theo vị trí, vì các
/// pattern trong danh sách có số lượng group khác nhau (không phải pattern
/// nào cũng bắt được dấu hoặc đơn vị tiền tệ). Bên gọi (transaction_parser.dart)
/// luôn kiểm tra `match.groupNames.contains(...)` trước khi đọc named group,
/// nên thêm pattern mới thiếu group nào đó cũng không làm crash parser.
final List<RegExp> amountSignPatterns = [
  // Có đơn vị tiền tệ đi kèm, dấu +/- là optional: +2,000,000 VND /
  // -350.000 VNĐ / 300,000 VND (không dấu — loại giao dịch sẽ được suy luận
  // riêng từ incomeKeywords/expenseKeywords khi sign không xác định được).
  RegExp(
    r'(?<sign>[+\-])?\s*(?<amount>\d[\d.,]*)\s*(?<currency>VND|VNĐ|₫|đ)\b',
    caseSensitive: false,
  ),
  // Không ghi rõ đơn vị tiền tệ, nhưng có dấu +/- đứng trước một số được
  // phân nhóm hàng nghìn rõ ràng (>= 4 chữ số) — fallback khi bank không kèm
  // ký hiệu tiền tệ ngay sau số. Bắt buộc phải có dấu ở pattern này vì không
  // có "currency" để neo, thiếu dấu sẽ dễ khớp nhầm số khác trong nội dung
  // (mã giao dịch, số điện thoại...).
  RegExp(r'(?<sign>[+\-])\s*(?<amount>\d{1,3}(?:[.,]\d{3})+)\b'),
];

/// Từ khoá (không dấu, chữ thường) dùng suy luận loại giao dịch khi không có
/// dấu +/- rõ ràng đứng trước số tiền.
final List<String> incomeKeywords = [
  'gd co',
  'ghi co',
  'nhan tien',
  'cong tien',
  'tien vao',
];

final List<String> expenseKeywords = [
  'gd no',
  'ghi no',
  'thanh toan',
  'tru tien',
  'tien ra',
  'rut tien',
];

/// Số tài khoản đã che, ví dụ "****1234" hoặc "1234****".
final List<RegExp> accountPatterns = [
  RegExp(r'(?:TK|Tai khoan|Tài khoản)\s*[:\.]?\s*([\d*]{4,20})', caseSensitive: false),
  RegExp(r'\b(\*{2,}\d{2,8})\b'),
  RegExp(r'\b(\d{2,8}\*{2,})\b'),
];

/// Nội dung chuyển khoản, đứng sau nhãn "ND:"/"Nội dung:"/"Noi dung:".
/// Dùng \b thay vì neo vào đầu dòng, vì notification có thể bị dồn về một
/// dòng duy nhất (không còn \n) khi Android không dùng BigTextStyle.
final List<RegExp> descriptionPatterns = [
  RegExp(r'\b(?:ND|Noi dung|Nội dung)\s*[:\.]?\s*(.+)', caseSensitive: false),
];

/// Dùng để cắt phần nội dung nếu notification bị dồn về một dòng (không có
/// \n) và regex mô tả ở trên vô tình "ăn" luôn cả nhãn tiếp theo (ví dụ
/// "SD:") vào trong phần nội dung capture được.
final RegExp nextLabelPattern = RegExp(
  r'\b(?:SD|So du|Số dư|Ma GD|Mã GD|GD so)\s*[:\.]',
  caseSensitive: false,
);

/// Số dư sau giao dịch, đứng sau nhãn "SD:"/"Số dư:"/"So du:".
final List<RegExp> balancePatterns = [
  RegExp(r'(?:SD|So du|Số dư)\s*[:\.]?\s*([\d.,]+)', caseSensitive: false),
];

/// Mã giao dịch, nếu notification có cung cấp.
final List<RegExp> transactionCodePatterns = [
  RegExp(r'(?:Ma\s*GD|Mã\s*GD|Ref|FT|GD\s*so)\s*[:\.]?\s*([A-Za-z0-9]{4,})', caseSensitive: false),
];

/// Thời gian giao dịch tường minh trong nội dung, dạng dd/MM/yyyy HH:mm[:ss].
/// Nếu không khớp, parser sẽ dùng thời gian post của notification thay thế.
final List<RegExp> dateTimePatterns = [
  RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?'),
];
