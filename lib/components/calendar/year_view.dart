// 年视图 — 12 个月的小日历网格
// 对应原项目的 components/calendar/YearView.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/domain/lunar.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/stores/view_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

class YearView extends StatefulWidget {
  final int displayYear;

  const YearView({super.key, required this.displayYear});

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  late int _displayYear;

  @override
  void initState() {
    super.initState();
    _displayYear = widget.displayYear;
  }

  @override
  void didUpdateWidget(YearView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayYear != oldWidget.displayYear) {
      _displayYear = widget.displayYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final viewStore = context.watch<ViewStore>();
    final selectedDate = DateTime.parse(viewStore.selectedDate);

    return Container(
      color: colors.background,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -300) {
            setState(() => _displayYear++);
          } else if (velocity > 300) {
            setState(() => _displayYear--);
          }
        },
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final isSelectedMonth =
                _displayYear == selectedDate.year && month == selectedDate.month;

            return _MiniMonthGrid(
              year: _displayYear,
              month: month,
              isSelectedMonth: isSelectedMonth,
              colors: colors,
              onTap: () {
                // 点击月份跳转到月视图
                final now = DateTime.now();
                final target = (_displayYear == now.year && month == now.month)
                    ? _toIsoDate(now)
                    : _toIsoDate(DateTime(_displayYear, month, 1));
                viewStore.setSelectedDateAndMonth(target);
                viewStore.setCurrentView(ViewType.month);
              },
            );
          },
        ),
      ),
    );
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

/// 迷你月网格（年视图中的小月份）
class _MiniMonthGrid extends StatelessWidget {
  final int year;
  final int month;
  final bool isSelectedMonth;
  final AppColors colors;
  final VoidCallback onTap;

  const _MiniMonthGrid({
    required this.year,
    required this.month,
    required this.isSelectedMonth,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE8563A);

    // 获取农历假日集合用于标记
    final lunarInfoMap = getLunarInfoBatch(year, month);
    final holidayDates = <String>{};
    for (final entry in lunarInfoMap.entries) {
      if (entry.value.isHoliday) {
        holidayDates.add(entry.key);
      }
    }

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final calStart = _sundayOfWeek(firstDay);
    final calEnd = _saturdayOfWeek(lastDay);

    final days = <DateTime>[];
    for (var d = calStart;
        !d.isAfter(calEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final now = DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 月份标题
          Text(
            '$month月',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isSelectedMonth ? primaryColor : colors.text,
            ),
          ),
          const SizedBox(height: 4),
          // 星期标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['日', '一', '二', '三', '四', '五', '六']
                .map((label) => SizedBox(
                      width: 14,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: colors.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 2),
          // 日期格子
          Wrap(
            spacing: 0,
            runSpacing: 1,
            children: days.map((day) {
              final isCurrentMonth = day.month == month && day.year == year;
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final dateStr = _toIsoDate(day);
              final isHoliday = holidayDates.contains(dateStr);

              return SizedBox(
                width: 14,
                height: 14,
                child: Center(
                  child: isCurrentMonth
                      ? Container(
                          decoration: isToday
                              ? const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                )
                              : null,
                          child: Text(
                            '${day.day}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: isToday
                                  ? Colors.white
                                  : isHoliday
                                      ? primaryColor
                                      : colors.text,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  DateTime _sundayOfWeek(DateTime date) {
    final weekday = date.weekday;
    // weekday: 1=周一..7=周日，周日=7
    return date.subtract(Duration(days: weekday % 7));
  }

  DateTime _saturdayOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 6 - weekday % 7));
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
