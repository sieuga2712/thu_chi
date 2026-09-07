import 'package:equatable/equatable.dart';

/// Một đoạn thời gian rời khỏi app trong lúc đồng hồ Nghiêm ngặt đang chạy.
/// [end] là null nếu đoạn sao nhãng đang diễn ra (chưa quay lại app).
class DistractionInterval extends Equatable {
  const DistractionInterval({required this.start, this.end});

  final DateTime start;
  final DateTime? end;

  DistractionInterval copyWithEnd(DateTime end) {
    return DistractionInterval(start: start, end: end);
  }

  Duration get duration => (end ?? DateTime.now()).difference(start);

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end?.toIso8601String(),
  };

  factory DistractionInterval.fromJson(Map<String, dynamic> json) {
    return DistractionInterval(
      start: DateTime.parse(json['start'] as String),
      end: json['end'] == null ? null : DateTime.parse(json['end'] as String),
    );
  }

  @override
  List<Object?> get props => [start, end];
}
