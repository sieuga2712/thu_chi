/// Phân loại 1 hoạt động — quyết định hoạt động sống ở tab nào và cơ chế
/// theo dõi ra sao.
enum ActivityKind {
  /// Hoạt động tính giờ (Bắt đầu/Dừng), tích lũy thời gian — sống ở tab
  /// Thành tựu.
  timed,

  /// Hoạt động dạng tick xong trong ngày — sống ở tab Hoạt động.
  checkbox;

  String get label => switch (this) {
    ActivityKind.timed => 'Tính giờ',
    ActivityKind.checkbox => 'Checkbox',
  };
}
