/// Lĩnh vực của một hoạt động — chỉ dùng để nhóm/hiển thị, không ảnh hưởng
/// cơ chế đồng hồ.
enum ActivityDomain {
  health,
  learning,
  work,
  personal;

  String get label => switch (this) {
    ActivityDomain.health => 'Sức khỏe',
    ActivityDomain.learning => 'Học tập',
    ActivityDomain.work => 'Công việc',
    ActivityDomain.personal => 'Sinh hoạt',
  };
}
