import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'retro_style.dart';

/// Theme Material 3 cho app — phong cách pixel/RPG retro (kiểu GBA) áp dụng
/// cho khung/nút bấm/nhãn TOÀN APP (AppBar, bottom nav, viền Card, chip,
/// viền input, nút bấm). CỐ TÌNH không đổi [ThemeData.textTheme] — các role
/// như titleMedium/titleLarge/bodySmall đang bị dùng lẫn lộn cho cả nhãn
/// trang trí LẪN số tiền/số dư ở nhiều màn hình (ví dụ StatCard, TransactionTile
/// balance, TransactionDetailScreen headlineMedium) nên đổi font ở đây sẽ vô
/// tình làm số liệu tài chính khó đọc. Xem [RetroStyle].
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );

    const retroBorder = BorderSide(color: RetroStyle.borderDark, width: 3);
    const sharpShape = RoundedRectangleBorder(side: retroBorder);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RetroStyle.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: RetroStyle.appBarBackground,
        foregroundColor: RetroStyle.appBarForeground,
        titleTextStyle: RetroStyle.titleTextStyle,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: RetroStyle.panelFill,
        surfaceTintColor: Colors.transparent,
        shape: sharpShape,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 1,
        height: 64,
        backgroundColor: RetroStyle.appBarBackground,
        indicatorColor: RetroStyle.appBarForeground.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? RetroStyle.appBarForeground
                : RetroStyle.appBarForeground.withValues(alpha: 0.6),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 14,
            color: states.contains(WidgetState.selected)
                ? RetroStyle.appBarForeground
                : RetroStyle.appBarForeground.withValues(alpha: 0.6),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: RetroStyle.panelFill,
        hintStyle: RetroStyle.labelTextStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: retroBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: retroBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: retroBorder,
        ),
      ),
      // Nền/chữ đặt tường minh cho CẢ 2 trạng thái chọn/chưa chọn: chữ luôn
      // borderDark (đậm), chỉ nền đổi (trắng ngà -> vàng nhấn) khi chọn — để
      // không bao giờ rơi vào trường hợp chữ trùng màu nền (ví dụ chữ trắng
      // trên nền trắng) như đã xảy ra khi chỉ đổi font mà bỏ trống màu.
      chipTheme: ChipThemeData(
        backgroundColor: RetroStyle.panelFill,
        selectedColor: RetroStyle.accentSelected,
        disabledColor: RetroStyle.panelFill,
        labelStyle: const TextStyle(
          fontFamily: RetroStyle.fontFamily,
          fontSize: 18,
          color: RetroStyle.borderDark,
        ),
        checkmarkColor: RetroStyle.borderDark,
        shape: RetroStyle.chipShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: sharpShape,
          textStyle: const TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 18,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: sharpShape,
          side: retroBorder,
          textStyle: const TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 18,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RetroStyle.appBarBackground,
        foregroundColor: RetroStyle.appBarForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: retroBorder,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
