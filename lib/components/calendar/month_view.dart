// 月视图 — 可滑动的月份日历，支持折叠手势
// 对应原项目的 components/calendar/MonthView.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/components/calendar/day_info_panel.dart';
import 'package:yaya_calendar/components/calendar/month_grid.dart';
import 'package:yaya_calendar/domain/lunar.dart';
import 'package:yaya_calendar/stores/event_store.dart';
import 'package:yaya_calendar/stores/view_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 星期标签
const List<String> _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final viewStore = context.watch<ViewStore>();
    final eventStore = context.watch<EventStore>();

    final displayMonth = DateTime.parse(viewStore.displayMonth);
    final year = displayMonth.year;
    final month = displayMonth.month;

    // 预计算农历和事件数据
    final lunarInfoMap = getLunarInfoBatch(year, month);
    final eventsMap = eventStore.getEventsForMonth(year, month);

    return Container(
      color: colors.background,
      child: Column(
        children: [
          // 星期标签
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekdays.asMap().entries.map((entry) {
                final idx = entry.key;
                final label = entry.value;
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 7 - 4.6,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: idx >= 5
                          ? colors.weekendText
                          : colors.textTertiary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 可滑动的月网格
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -300) {
                  // 向左滑 → 下月
                  _goToNextMonth(viewStore);
                } else if (velocity > 300) {
                  // 向右滑 → 上月
                  _goToPrevMonth(viewStore);
                }
              },
              // 垂直拖拽控制折叠
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -200 && !_isCollapsed) {
                  setState(() => _isCollapsed = true);
                } else if (velocity > 200 && _isCollapsed) {
                  setState(() => _isCollapsed = false);
                }
              },
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MonthGrid(
                    year: year,
                    month: month,
                    lunarInfoMap: lunarInfoMap,
                    eventsMap: eventsMap,
                  ),
                ),
              ),
            ),
          ),
          // 折叠指示器
          GestureDetector(
            onTap: () {
              if (_isCollapsed) {
                setState(() => _isCollapsed = false);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Icon(
                _isCollapsed ? Icons.expand_more : Icons.remove,
                size: 20,
                color: colors.textTertiary,
              ),
            ),
          ),
          // 日期信息面板（限制最大高度避免溢出）
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: DayInfoPanel(date: viewStore.selectedDate),
          ),
        ],
      ),
    );
  }

  void _goToNextMonth(ViewStore viewStore) {
    final current = DateTime.parse(viewStore.displayMonth);
    final next = DateTime(current.year, current.month + 1, 1);
    viewStore.setHasNavigatedMonth(true);
    final now = DateTime.now();
    final target = (next.year == now.year && next.month == now.month)
        ? _toIsoDate(now)
        : _toIsoDate(next);
    viewStore.setSelectedDateAndMonth(target);
  }

  void _goToPrevMonth(ViewStore viewStore) {
    final current = DateTime.parse(viewStore.displayMonth);
    final prev = DateTime(current.year, current.month - 1, 1);
    viewStore.setHasNavigatedMonth(true);
    final now = DateTime.now();
    final target = (prev.year == now.year && prev.month == now.month)
        ? _toIsoDate(now)
        : _toIsoDate(prev);
    viewStore.setSelectedDateAndMonth(target);
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
