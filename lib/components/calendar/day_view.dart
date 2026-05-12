// 日视图 — 显示一天的时间轴和事件
// 对应原项目的 components/calendar/DayView.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/domain/lunar.dart';
import 'package:yaya_calendar/stores/view_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

const double _hourHeight = 60.0;

class DayView extends StatelessWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final viewStore = context.watch<ViewStore>();

    final selectedDate = DateTime.parse(viewStore.selectedDate);
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final lunarInfo = getLunarInfo(selectedDate);

    return Container(
      color: colors.background,
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              children: [
                Text(
                  '${selectedDate.day}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weekdayName(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      lunarInfo.holiday ??
                          lunarInfo.solarTerm ??
                          lunarInfo.lunarDay,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '今天',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 时间轴
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemExtent: _hourHeight,
              itemBuilder: (context, index) {
                final hour = index;
                final isCurrentHour = isToday && hour == now.hour;

                return Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          // 网格线
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: colors.border),
                              ),
                            ),
                          ),
                          // 当前时间指示器
                          if (isCurrentHour)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child: Container(
                                height: 2,
                                color: colors.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayName(DateTime date) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[date.weekday - 1];
  }
}
