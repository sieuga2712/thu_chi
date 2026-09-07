/// Chế độ giám sát khi đồng hồ đang chạy.
enum ActivitySupervisionMode {
  /// Rời app/khóa màn hình không sao — thời gian tính theo mốc bắt đầu/kết
  /// thúc thật, không cần app luôn mở.
  relaxed,

  /// Rời app trong lúc đang chạy sẽ được ghi lại thành một đoạn "sao nhãng".
  ///
  /// Bản v1: CHƯA phân biệt được "khóa màn hình" (không nên phạt) và
  /// "chuyển sang app khác" (nên tính sao nhãng) — cả hai đều tính là sao
  /// nhãng vì mới chỉ dùng [AppLifecycleState] của Flutter, chưa có code
  /// native theo dõi riêng sự kiện màn hình sáng/tắt. Có thể tinh chỉnh sau.
  strict;

  String get label => switch (this) {
    ActivitySupervisionMode.relaxed => 'Thoải mái',
    ActivitySupervisionMode.strict => 'Nghiêm ngặt',
  };
}
