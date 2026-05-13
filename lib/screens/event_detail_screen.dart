// 事件详情页 — 展示事件完整信息，支持编辑和删除
// 对应原项目的 app/(tabs)/index.tsx（事件详情路由）

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/components/common/app_modal.dart';
import 'package:yaya_calendar/components/forms/event_form.dart';
import 'package:yaya_calendar/domain/lunar.dart';
import 'package:yaya_calendar/stores/event_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final eventStore = context.watch<EventStore>();
    final event = eventStore.getEventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '事件不存在',
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    final startDate = DateTime.parse(event.startTime);
    final endDate = DateTime.parse(event.endTime);
    final lunarInfo = getLunarInfo(startDate);
    final lunarDate = toLunarDate(startDate);

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部导航栏
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 8,
              ),
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.chevron_left, color: colors.primary),
                label: Text('返回', style: TextStyle(color: colors.primary)),
              ),
            ),

            // 事件卡片
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 颜色条
                  Container(height: 4, color: _parseColor(event.color)),
                  // 标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // 时间信息
                  _InfoSection(
                    label: '时间',
                    colors: colors,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(startDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatTime(startDate)} - ${_formatTime(endDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '农历 ${lunarDate.monthName}${lunarDate.dayName}'
                          '${lunarInfo.solarTerm != null ? ' · ${lunarInfo.solarTerm}' : ''}'
                          '${lunarInfo.holiday != null ? ' · ${lunarInfo.holiday}' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 描述
                  if (event.description != null &&
                      event.description!.isNotEmpty)
                    _InfoSection(
                      label: '描述',
                      colors: colors,
                      child: Text(
                        event.description!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: colors.text,
                        ),
                      ),
                    ),
                  // 重复
                  if (event.recurrenceRule != null)
                    _InfoSection(
                      label: '重复',
                      colors: colors,
                      child: Text(
                        _frequencyLabel(event.recurrenceRule!.frequency),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colors.text,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 操作按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final event = context.read<EventStore>().getEventById(
                          widget.eventId,
                        );
                        if (event == null || !mounted) return;
                        AppModal.show(
                          context: context,
                          title: '编辑事件',
                          child: EventForm(
                            event: event,
                            onSave: () => Navigator.of(context).pop(),
                            onCancel: () => Navigator.of(context).pop(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8563A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '编辑',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _deleting ? null : _handleDelete,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _deleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('删除', style: TextStyle(color: colors.text)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除事件'),
        content: const Text('确定要删除这个事件吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final eventStore = context.read<EventStore>();
      await eventStore.deleteEvent(widget.eventId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除失败，请重试')));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 $weekday';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _frequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return '每天';
      case 'weekly':
        return '每周';
      case 'monthly':
        return '每月';
      case 'yearly':
        return '每年';
      default:
        return frequency;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF8B5CF6);
    }
  }
}

/// 信息区块
class _InfoSection extends StatelessWidget {
  final String label;
  final AppColors colors;
  final Widget child;

  const _InfoSection({
    required this.label,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
