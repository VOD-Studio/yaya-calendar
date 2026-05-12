// 日历头部组件 — 显示年月标题和周数
// 对应原项目的 components/common/CalendarHeader.tsx

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/stores/view_store.dart';

class CalendarHeader extends StatelessWidget {
  final VoidCallback? onYearViewPress;

  const CalendarHeader({super.key, this.onYearViewPress});

  @override
  Widget build(BuildContext context) {
    final viewStore = context.watch<ViewStore>();
    final selectedDate = DateTime.parse(viewStore.selectedDate);
    final currentView = viewStore.currentView;

    final yearText = '${selectedDate.year}年';
    final monthText = DateFormat('yyyy年M月', 'zh_CN').format(selectedDate);
    final weekNumber = _getWeekNumber(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 16),
          Row(
            children: [
              // 年视图返回箭头
              if (currentView == ViewType.month && onYearViewPress != null)
                GestureDetector(
                  onTap: onYearViewPress,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.chevron_left, size: 24),
                  ),
                ),
              // 标题
              Text(
                currentView == ViewType.year ? yearText : monthText,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              // 周数
              if (currentView == ViewType.month)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '第$weekNumber周',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 计算 ISO 周数
  int _getWeekNumber(DateTime date) {
    final jan1 = DateTime(date.year, 1, 1);
    final daysSinceJan1 = date.difference(jan1).inDays;
    final jan1Weekday = jan1.weekday;
    return ((daysSinceJan1 + jan1Weekday - 1) / 7).ceil();
  }
}
