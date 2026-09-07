import '../../../models/activity_session.dart';

class StreakResult {
  const StreakResult({required this.current, required this.longest});

  /// Số ngày liên tiếp (tính đến hôm nay hoặc hôm qua) có ít nhất 1 hoạt
  /// động được ghi nhận. 0 nếu chuỗi đã đứt (hôm nay VÀ hôm qua đều không
  /// có hoạt động nào).
  final int current;

  /// Chuỗi dài nhất từng đạt được trong toàn bộ lịch sử.
  final int longest;
}

/// Tính streak tổng (không tách riêng theo từng hoạt động) — một ngày được
/// tính là "có hoạt động" nếu có ít nhất 1 phiên bắt đầu trong ngày đó, bất
/// kể thuộc hoạt động nào.
StreakResult computeStreak(List<ActivitySession> sessions, {DateTime? now}) {
  if (sessions.isEmpty) return const StreakResult(current: 0, longest: 0);

  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);

  final activeDays = sessions.map((s) {
    final d = s.startedAt;
    return DateTime(d.year, d.month, d.day);
  }).toSet();

  final sortedDays = activeDays.toList()..sort();

  // Streak hiện tại: đếm lùi từ hôm nay (hoặc hôm qua nếu hôm nay chưa có
  // hoạt động nào — vẫn coi là chuỗi đang sống, chưa đứt).
  var current = 0;
  var cursor = activeDays.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  while (activeDays.contains(cursor)) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  // Streak dài nhất: quét toàn bộ các ngày có hoạt động, tìm dải liên tiếp
  // dài nhất.
  var longest = 0;
  var run = 0;
  DateTime? previous;
  for (final day in sortedDays) {
    if (previous != null && day.difference(previous).inDays == 1) {
      run++;
    } else {
      run = 1;
    }
    if (run > longest) longest = run;
    previous = day;
  }

  return StreakResult(current: current, longest: longest);
}
