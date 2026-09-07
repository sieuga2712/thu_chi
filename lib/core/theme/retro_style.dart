import 'package:flutter/material.dart';

/// Style phong cách pixel/RPG retro (kiểu GBA) — hiện chỉ áp dụng thử cho
/// tab Giao dịch, dùng font VT323 (đã kiểm tra hỗ trợ đầy đủ dấu tiếng Việt)
/// cho khung/nhãn/nút bấm. Số tiền và nội dung giao dịch CỐ TÌNH giữ font
/// mặc định để không ảnh hưởng độ dễ đọc của số liệu tài chính.
class RetroStyle {
  RetroStyle._();

  static const fontFamily = 'VT323';

  static const background = Color(0xFFF4ECD8);
  static const panelFill = Color(0xFFFFFDF5);
  static const borderDark = Color(0xFF1B1B3A);
  static const appBarBackground = Color(0xFF1B1B3A);
  static const appBarForeground = Color(0xFFFFFDF5);

  /// Màu nhấn khi một lựa chọn đang được chọn (chip/tab) — cố tình chọn màu
  /// SÁNG (không phải [borderDark]) để chữ [borderDark] luôn đọc được trên
  /// cả 2 trạng thái chọn/chưa chọn, không cần đổi màu chữ theo state.
  static const accentSelected = Color(0xFFF5D67A);

  static const titleTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    color: appBarForeground,
    letterSpacing: 1,
  );

  static const labelTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: borderDark,
  );

  static const labelOnDarkTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: appBarForeground,
  );

  /// Khung viền dày, bóng đổ cứng (không bo góc, không blur) — thay cho
  /// elevation/border-radius mềm mại của Material mặc định. Dùng cho nội
  /// dung KHÔNG cần ripple/ink (ví dụ Card tĩnh).
  static BoxDecoration panel({Color? fill}) => BoxDecoration(
    color: fill ?? panelFill,
    border: Border.all(color: borderDark, width: 3),
    boxShadow: const [BoxShadow(color: borderDark, offset: Offset(4, 4))],
  );

  /// Viền + bóng đổ nhưng KHÔNG có màu nền — dùng khi bên trong là widget
  /// cần vẽ ripple/ink (ví dụ ListTile), để tránh che mất hiệu ứng đó (màu
  /// nền phải đặt ở [Material] bên trong, không phải ở Container bọc ngoài).
  static BoxDecoration get panelBorderOnly => BoxDecoration(
    border: Border.all(color: borderDark, width: 3),
    boxShadow: const [BoxShadow(color: borderDark, offset: Offset(4, 4))],
  );

  static final RoundedRectangleBorder chipShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),
    side: const BorderSide(color: borderDark, width: 2),
  );
}

/// Khung icon vuông sắc cạnh có viền — thay cho [CircleAvatar] tròn mềm mại
/// mặc định, để icon (vẫn là icon Material gốc) hòa hợp với phong cách pixel
/// retro của khung/nút bấm xung quanh. Không "vẽ lại" icon thành pixel art
/// thật — chỉ đổi phần khung/nền quanh icon.
class RetroIconBadge extends StatelessWidget {
  const RetroIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 36,
    this.iconSize = 18,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
