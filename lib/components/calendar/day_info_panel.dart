// 日期信息面板 — 显示选中日期的农历详情和事件列表
// 对应原项目的 components/calendar/DayInfoPanel.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/domain/lunar.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/stores/event_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

class DayInfoPanel extends StatelessWidget {
  final String date; // ISO 格式日期

  const DayInfoPanel({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final eventStore = context.watch<EventStore>();
    final events = eventStore.getEventsForDate(date);
    final dateInfo = _getDateInfo(date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    dateInfo.relativeLabel,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateInfo.formattedDate,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                dateInfo.lunarInfo,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          if (dateInfo.festival != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                dateInfo.festival!,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ),
          // 事件列表
          if (events.isNotEmpty) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _EventCard(event: events[index]);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  _DateDisplayInfo _getDateInfo(String dateStr) {
    final date = DateTime.parse(dateStr);
    final lunar = toLunarDate(date);
    final solarTerm = getSolarTerm(date);
    final holidays = getHolidays(date);
    final now = DateTime.now();

    // 相对日期
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    String relativeLabel;
    if (diff == 0) {
      relativeLabel = '今天';
    } else if (diff > 0) {
      relativeLabel = '$diff天后';
    } else {
      relativeLabel = '${diff.abs()}天前';
    }

    // 农历信息
    final lunarParts = <String>[];
    lunarParts.add(lunar.day == 1 ? lunar.monthName : lunar.dayName);
    lunarParts.add('${lunar.yearGanZhi}(${lunar.yearShengXiao})');
    if (solarTerm != null) lunarParts.add(solarTerm.name);

    // 节日
    final festivals = holidays.where((h) => h.type != 'solar_term').toList();

    return _DateDisplayInfo(
      relativeLabel: relativeLabel,
      formattedDate: '${date.month}月${date.day}日',
      lunarInfo: lunarParts.join(' '),
      festival: festivals.isNotEmpty ? festivals.first.name : null,
    );
  }
}

class _DateDisplayInfo {
  final String relativeLabel;
  final String formattedDate;
  final String lunarInfo;
  final String? festival;

  _DateDisplayInfo({
    required this.relativeLabel,
    required this.formattedDate,
    required this.lunarInfo,
    this.festival,
  });
}

/// 事件卡片
class _EventCard extends StatelessWidget {
  final CalendarEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final start = DateTime.parse(event.startTime);
    final end = DateTime.parse(event.endTime);
    final timeRange =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'
        '-${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 左侧颜色条
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: _parseColor(event.color),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
            ),
          ),
          // 事件内容
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeRange,
                    style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  ),
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
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
