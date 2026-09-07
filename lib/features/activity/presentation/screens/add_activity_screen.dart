import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/retro_style.dart';
import '../../../../models/activity_domain.dart';
import '../../../../models/activity_goal_frequency.dart';
import '../../../../models/activity_kind.dart';
import '../../../../models/activity_supervision_mode.dart';
import '../../../../models/activity_timer_type.dart';
import '../../models/activity_icon_catalog.dart';
import '../../providers/activities_provider.dart';

/// Tạo một hoạt động mới. Nội dung form phụ thuộc [kind] — nơi gọi màn
/// hình này (Hoạt động → checkbox, Thành tựu → tính giờ) quyết định luôn,
/// không cho đổi trong form để giảm số lựa chọn.
class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key, required this.kind});

  final ActivityKind kind;

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _nameController = TextEditingController();
  final _minutesController = TextEditingController(text: '25');
  final _weeklyGoalController = TextEditingController(text: '3');

  // Nhánh "timed".
  ActivityDomain _domain = ActivityDomain.personal;
  ActivityTimerType _timerType = ActivityTimerType.stopwatch;
  ActivitySupervisionMode _supervisionMode = ActivitySupervisionMode.relaxed;

  // Nhánh "checkbox".
  String _icon = ActivityIconCatalog.options.first.key;
  ActivityGoalFrequency _goalFrequency = ActivityGoalFrequency.daily;

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    _weeklyGoalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nhập tên hoạt động')));
      return;
    }

    if (widget.kind == ActivityKind.checkbox) {
      await _saveCheckbox(name);
    } else {
      await _saveTimed(name);
    }
  }

  Future<void> _saveCheckbox(String name) async {
    int? weeklyGoalCount;
    if (_goalFrequency == ActivityGoalFrequency.weekly) {
      weeklyGoalCount = int.tryParse(_weeklyGoalController.text.trim());
      if (weeklyGoalCount == null ||
          weeklyGoalCount <= 0 ||
          weeklyGoalCount > 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nhập số buổi mục tiêu từ 1 đến 7')),
        );
        return;
      }
    }

    setState(() => _saving = true);
    await ref
        .read(activitiesProvider.notifier)
        .addCheckbox(
          name: name,
          icon: _icon,
          goalFrequency: _goalFrequency,
          weeklyGoalCount: weeklyGoalCount,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _saveTimed(String name) async {
    int? countdownMinutes;
    if (_timerType == ActivityTimerType.countdown) {
      countdownMinutes = int.tryParse(_minutesController.text.trim());
      if (countdownMinutes == null || countdownMinutes <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nhập số phút đếm ngược hợp lệ')),
        );
        return;
      }
    }

    setState(() => _saving = true);
    await ref
        .read(activitiesProvider.notifier)
        .add(
          name: name,
          domain: _domain,
          timerType: _timerType,
          countdownMinutes: countdownMinutes,
          supervisionMode: _supervisionMode,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.kind == ActivityKind.checkbox
              ? 'Thêm hoạt động'
              : 'Thêm hoạt động tính giờ',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(
              fontFamily: RetroStyle.fontFamily,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              labelText: 'Tên hoạt động',
              hintText: 'Ví dụ: Chuẩn bị đồ đạc',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.kind == ActivityKind.checkbox)
            ..._buildCheckboxForm()
          else
            ..._buildTimedForm(),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Đang lưu...' : 'Lưu hoạt động'),
          ),
          SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  List<Widget> _buildCheckboxForm() {
    return [
      _SectionLabel('Icon'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ActivityIconCatalog.options.map((option) {
          final selected = option.key == _icon;
          return ChoiceChip(
            avatar: Icon(option.icon, size: 18),
            label: Text(option.label),
            selected: selected,
            onSelected: (_) => setState(() => _icon = option.key),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      _SectionLabel('Tần suất'),
      const SizedBox(height: 8),
      SegmentedButton<ActivityGoalFrequency>(
        segments: ActivityGoalFrequency.values
            .map((f) => ButtonSegment(value: f, label: Text(f.label)))
            .toList(),
        selected: {_goalFrequency},
        onSelectionChanged: (s) => setState(() => _goalFrequency = s.first),
      ),
      if (_goalFrequency == ActivityGoalFrequency.weekly) ...[
        const SizedBox(height: 12),
        TextField(
          key: const Key('weekly_goal_field'),
          controller: _weeklyGoalController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
            labelText: 'Số buổi mục tiêu/tuần',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildTimedForm() {
    return [
      _SectionLabel('Lĩnh vực'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ActivityDomain.values.map((d) {
          return ChoiceChip(
            label: Text(d.label),
            selected: _domain == d,
            onSelected: (_) => setState(() => _domain = d),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      _SectionLabel('Kiểu đồng hồ'),
      const SizedBox(height: 8),
      SegmentedButton<ActivityTimerType>(
        segments: ActivityTimerType.values
            .map((t) => ButtonSegment(value: t, label: Text(t.label)))
            .toList(),
        selected: {_timerType},
        onSelectionChanged: (s) => setState(() => _timerType = s.first),
      ),
      if (_timerType == ActivityTimerType.countdown) ...[
        const SizedBox(height: 12),
        TextField(
          controller: _minutesController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontFamily: RetroStyle.fontFamily,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
            labelText: 'Số phút đếm ngược',
            border: OutlineInputBorder(),
          ),
        ),
      ],
      const SizedBox(height: 20),
      _SectionLabel('Chế độ giám sát'),
      const SizedBox(height: 8),
      SegmentedButton<ActivitySupervisionMode>(
        segments: ActivitySupervisionMode.values
            .map((m) => ButtonSegment(value: m, label: Text(m.label)))
            .toList(),
        selected: {_supervisionMode},
        onSelectionChanged: (s) => setState(() => _supervisionMode = s.first),
      ),
      const SizedBox(height: 4),
      Text(
        _supervisionMode == ActivitySupervisionMode.strict
            ? 'Rời app trong lúc đồng hồ chạy sẽ được ghi lại thành "sao nhãng" (không trừ điểm, chỉ để bạn tự xem lại).'
            : 'Rời app/khóa màn hình lúc đồng hồ chạy không sao — phù hợp việc như tập gym.',
        style: const TextStyle(color: Colors.black54, fontSize: 13),
      ),
    ];
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: RetroStyle.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
