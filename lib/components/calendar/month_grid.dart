// 月网格组件 — 显示一个月的日历格子
// 对应原项目的 components/calendar/MonthGrid.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/stores/event_store.dart';
import 'package:yaya_calendar/stores/view_store.dart';
import 'package:yaya_calendar/styles/theme.dart';
import 'package:yaya_calendar/utils/work_schedule.dart';

class MonthGrid extends StatelessWidget {
  final int year;
  final int month; // 1-12
  final Map<String, LunarInfo>? lunarInfoMap;
  final Map<String, List<CalendarEvent>>? eventsMap;

  const MonthGrid({
    super.key,
    required this.year,
    required this.month,
    this.lunarInfoMap,
    this.eventsMap,
  });

  @override
  Widget build(BuildContext context) {
    final viewStore = context.watch<ViewStore>();
    final eventStore = context.watch<EventStore>();
    final colors = getColors(context);

    // 计算日历日期范围
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final calStart = _mondayOfWeek(firstDay);
    final calEnd = _sundayOfWeek(lastDay);

    final days = <DateTime>[];
    for (var d = calStart;
        !d.isAfter(calEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    return Wrap(
      spacing: 0,
      runSpacing: 24,
      children: days.map((day) {
        return _DayCell(
          day: day,
          year: year,
          month: month,
          selectedDate: viewStore.selectedDate,
          colors: colors,
          lunarInfo: lunarInfoMap?[_toIsoDate(day)],
          events: eventsMap?[_toIsoDate(day)] ?? eventStore.getEventsForDate(_toIsoDate(day)),
          onTap: () {
            final dateStr = _toIsoDate(day);
            // 判断是否是当月日期
            if (day.month == month && day.year == year) {
              viewStore.setSelectedDateAndMonth(dateStr);
            }
          },
        );
      }).toList(),
    );
  }

  DateTime _mondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _sundayOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

/// 单个日期格子
class _DayCell extends StatelessWidget {
  final DateTime day;
  final int year;
  final int month;
  final String selectedDate;
  final AppColors colors;
  final LunarInfo? lunarInfo;
  final List<CalendarEvent> events;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.colors,
    required this.lunarInfo,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = _toIsoDate(day);
    final isCurrentMonth = day.month == month && day.year == year;
    final isToday = _isToday(day);
    final isSelected = selectedDate == dateStr;
    final isWeekend = day.weekday == 6 || day.weekday == 7;
    final workStatus = getWorkStatus(day);

    // 日期数字颜色
    Color textColor;
    if (!isCurrentMonth) {
      textColor = colors.textTertiary;
    } else if (isToday && isSelected) {
      textColor = Colors.white;
    } else if (isToday) {
      textColor = colors.text;
    } else if (isSelected) {
      textColor = const Color(0xFFE8563A); // primaryAccent
    } else if (isWeekend) {
      textColor = colors.weekendText;
    } else {
      textColor = colors.text;
    }

    // 背景
    Color bgColor = Colors.transparent;
    if (isToday && isSelected && isCurrentMonth) {
      bgColor = const Color(0xFFE8563A);
    }

    // 农历文字颜色
    Color lunarColor;
    if (!isCurrentMonth) {
      lunarColor = colors.textTertiary;
    } else if (lunarInfo?.isHoliday == true) {
      lunarColor = colors.holidayText;
    } else if (lunarInfo?.isSolarTerm == true) {
      lunarColor = colors.solarTermText;
    } else {
      lunarColor = colors.lunarText;
    }

    return GestureDetector(
      onTap: isCurrentMonth ? onTap : null,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 7 - 4.6,
        child: Column(
          children: [
            // 日期数字
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: isSelected && !isToday && isCurrentMonth
                        ? Border.all(color: const Color(0xFFE8563A), width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                // 班休标记
                if (workStatus == WorkStatus.work && isCurrentMonth)
                  Positioned(
                    top: -2,
                    right: -6,
                    child: Text(
                      '班',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                if (workStatus == WorkStatus.rest && isCurrentMonth)
                  Positioned(
                    top: -2,
                    right: -6,
                    child: Text(
                      '休',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                  ),
              ],
            ),
            // 农历文字
            if (lunarInfo != null)
              Text(
                lunarInfo?.holiday ??
                    lunarInfo?.solarTerm ??
                    lunarInfo?.lunarDay ??
                    '',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 8, color: lunarColor),
              ),
            // 事件点
            if (events.isNotEmpty && isCurrentMonth)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(3).map((e) {
                    return Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _parseColor(e.color),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF8B5CF6);
    }
  }
}
