// 事件创建/编辑表单
// 对应原项目的 components/forms/EventForm.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/stores/event_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 事件颜色选项
const List<String> _eventColors = [
  '#6366F1', // Indigo
  '#8B5CF6', // Violet
  '#EC4899', // Pink
  '#EF4444', // Red
  '#F59E0B', // Amber
  '#22C55E', // Green
  '#14B8A6', // Teal
  '#3B82F6', // Blue
];

/// 重复频率选项
const List<MapEntry<String, String>> _recurrenceOptions = [
  MapEntry('不重复', 'none'),
  MapEntry('每天', 'daily'),
  MapEntry('每周', 'weekly'),
  MapEntry('每月', 'monthly'),
  MapEntry('每年', 'yearly'),
];

class EventForm extends StatefulWidget {
  final CalendarEvent? event;
  final String? initialDate;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EventForm({
    super.key,
    this.event,
    this.initialDate,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  String _selectedColor = _eventColors[0];
  String _recurrence = 'none';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _dateController = TextEditingController(
      text: e?.startTime.split('T').first ??
          widget.initialDate ??
          _todayStr(),
    );
    _startTimeController = TextEditingController(
      text: e != null ? _extractTime(e.startTime) : '09:00',
    );
    _endTimeController = TextEditingController(
      text: e != null ? _extractTime(e.endTime) : '10:00',
    );
    _selectedColor = e?.color ?? _eventColors[0];
    _recurrence = e?.recurrenceRule?.frequency ?? 'none';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  String _todayStr() {
    final now = DateTime.now();
    return _toIsoDate(now);
  }

  String _extractTime(String? isoStr) {
    if (isoStr == null) return '09:00';
    final parts = isoStr.split('T');
    if (parts.length < 2) return '09:00';
    final timeParts = parts[1].split(':');
    return '${timeParts[0]}:${timeParts[1]}';
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _loading = true);
    try {
      final startDate = _dateController.text.trim();
      final startTime = _startTimeController.text.trim();
      final endTime = _endTimeController.text.trim();
      final description = _descController.text.trim();

      final eventData = {
        'title': title,
        'description': description.isEmpty ? null : description,
        'start_time': '${startDate}T$startTime:00',
        'end_time': '${startDate}T$endTime:00',
        'color': _selectedColor,
        'recurrence_rule': _recurrence != 'none'
            ? RecurrenceRule(frequency: _recurrence, interval: 1).toJson()
            : null,
      };

      final eventStore = context.read<EventStore>();
      if (widget.event != null) {
        await eventStore.updateEvent(widget.event!.id, eventData);
      } else {
        await eventStore.createEvent(eventData);
      }

      widget.onSave();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题输入
          _buildLabel('标题', colors),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: TextStyle(color: colors.text),
            decoration: InputDecoration(
              hintText: '输入事件标题',
              hintStyle: TextStyle(color: colors.textTertiary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 日期输入
          _buildLabel('日期', colors),
          const SizedBox(height: 6),
          TextField(
            controller: _dateController,
            style: TextStyle(color: colors.text),
            decoration: InputDecoration(
              hintText: 'YYYY-MM-DD',
              hintStyle: TextStyle(color: colors.textTertiary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 时间输入
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('开始时间', colors),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _startTimeController,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        hintText: 'HH:mm',
                        hintStyle: TextStyle(color: colors.textTertiary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('结束时间', colors),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _endTimeController,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        hintText: 'HH:mm',
                        hintStyle: TextStyle(color: colors.textTertiary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 描述输入
          _buildLabel('描述', colors),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            style: TextStyle(color: colors.text),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '添加描述（可选）',
              hintStyle: TextStyle(color: colors.textTertiary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 颜色选择
          _buildLabel('颜色', colors),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _eventColors.map((hex) {
              final isSelected = hex == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _parseColor(hex),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _parseColor(hex).withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 重复选项
          _buildLabel('重复', colors),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recurrenceOptions.map((option) {
              final isSelected = _recurrence == option.value;
              return GestureDetector(
                onTap: () => setState(() => _recurrence = option.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8563A)
                        : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE8563A)
                          : colors.border,
                    ),
                  ),
                  child: Text(
                    option.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : colors.text,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '取消',
                    style: TextStyle(color: colors.text),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed:
                      _titleController.text.trim().isEmpty || _loading
                          ? null
                          : _handleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE8563A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.event != null ? '保存' : '创建',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, AppColors colors) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF8B5CF6);
    }
  }
}
