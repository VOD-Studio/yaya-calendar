// 日程视图 — 按日期分组显示所有事件
// 对应原项目的 components/calendar/ScheduleView.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/domain/lunar.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/stores/event_store.dart';
import 'package:yaya_calendar/stores/view_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final eventStore = context.watch<EventStore>();
    final viewStore = context.watch<ViewStore>();

    final events = eventStore.events;
    if (events.isEmpty) {
      return Center(
        child: Text(
          '暂无日程安排',
          style: TextStyle(
            fontSize: 16,
            color: colors.textSecondary,
          ),
        ),
      );
    }

    // 按日期分组
    final eventsByDate = <String, List<CalendarEvent>>{};
    for (final event in events) {
      final dateKey = event.startTime.split('T').first;
      eventsByDate.putIfAbsent(dateKey, () => []).add(event);
    }
    final sortedDates = eventsByDate.keys.toList()..sort();

    final selectedDate = DateTime.parse(viewStore.selectedDate);
    final now = DateTime.now();

    return Column(
      children: [
        // 月标题
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 12,
          ),
          child: Row(
            children: [
              Text(
                '${selectedDate.year}年${selectedDate.month}月',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // 事件列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateStr = sortedDates[index];
              final date = DateTime.parse(dateStr);
              final dateEvents = eventsByDate[dateStr]!;

              // 日期标题
              String dateLabel;
              final today = DateTime(now.year, now.month, now.day);
              final target = DateTime(date.year, date.month, date.day);
              final diff = target.difference(today).inDays;
              if (diff == 0) {
                dateLabel = '今天';
              } else if (diff == 1) {
                dateLabel = '明天';
              } else {
                dateLabel = '${date.month}月${date.day}日 ${_weekdayName(date)}';
              }

              // 农历显示
              final lunarInfo = getLunarInfo(date);
              final lunarDisplay =
                  lunarInfo.holiday ?? lunarInfo.solarTerm ?? lunarInfo.lunarDay;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期头部
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lunarDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 事件卡片
                  ...dateEvents.map((event) => _EventCard(event: event)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _weekdayName(DateTime date) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[date.weekday - 1];
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final start = DateTime.parse(event.startTime);
    final end = DateTime.parse(event.endTime);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            width: 4,
            color: _parseColor(event.color),
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  '-${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (event.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      event.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
