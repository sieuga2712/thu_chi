import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/retro_style.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../models/activity_definition.dart';
import '../../logic/activity_timer_controller.dart';
import '../../logic/activity_timer_state.dart';

/// Một hoạt động trong danh sách "Hoạt động" — bấm Bắt đầu/Dừng ngay tại
/// đây. Khi hoạt động này đang chạy, hiển thị đồng hồ sống + đoạn sao nhãng
/// nếu có (chế độ Nghiêm ngặt).
class ActivityCard extends ConsumerWidget {
  const ActivityCard({super.key, required this.activity, this.onDelete});

  final ActivityDefinition activity;

  /// Khi có giá trị, hiện nút xóa (ẩn khi hoạt động này đang chạy — phải
  /// Dừng trước mới xóa được).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(activityTimerProvider);
    final isThisRunning = timerState.active?.activityId == activity.id;
    final isOtherRunning = timerState.isRunning && !isThisRunning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: RetroStyle.panel(
        fill: isThisRunning ? RetroStyle.accentSelected : RetroStyle.panelFill,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.name,
                  style: const TextStyle(
                    fontFamily: RetroStyle.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                activity.domain.label,
                style: const TextStyle(
                  fontFamily: RetroStyle.fontFamily,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              if (onDelete != null && !isThisRunning) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.expense,
                  tooltip: 'Xóa hoạt động',
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (isThisRunning)
            _buildRunning(context, ref, timerState)
          else
            _buildIdle(context, ref, isOtherRunning),
        ],
      ),
    );
  }

  Widget _buildRunning(
    BuildContext context,
    WidgetRef ref,
    ActivityTimerState timerState,
  ) {
    final remaining = timerState.countdownRemaining;
    final displayDuration = remaining ?? timerState.elapsed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          remaining != null
              ? 'Còn lại: ${DurationFormatter.formatClock(displayDuration)}'
              : DurationFormatter.formatClock(displayDuration),
          style: const TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (timerState.isDistracting) ...[
          const SizedBox(height: 4),
          Text(
            '⚠ Đang sao nhãng...',
            style: TextStyle(
              fontFamily: RetroStyle.fontFamily,
              fontSize: 16,
              color: AppColors.expense,
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else if (timerState.distractionElapsed > Duration.zero) ...[
          const SizedBox(height: 4),
          Text(
            'Sao nhãng: ${DurationFormatter.format(timerState.distractionElapsed)}',
            style: const TextStyle(
              fontFamily: RetroStyle.fontFamily,
              fontSize: 15,
              color: AppColors.expense,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => ref.read(activityTimerProvider.notifier).stop(),
            icon: const Icon(Icons.stop, size: 18),
            label: const Text('Dừng'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
          ),
        ),
      ],
    );
  }

  Widget _buildIdle(BuildContext context, WidgetRef ref, bool isOtherRunning) {
    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.icon(
        onPressed: isOtherRunning
            ? null
            : () => ref.read(activityTimerProvider.notifier).start(activity),
        icon: const Icon(Icons.play_arrow, size: 18),
        label: Text(isOtherRunning ? 'Đang có hoạt động khác chạy' : 'Bắt đầu'),
      ),
    );
  }
}
