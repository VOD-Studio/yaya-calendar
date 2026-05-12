// 重复事件展开逻辑
// 对应原项目的 domain/recurrence.ts

import 'package:yaya_calendar/domain/types.dart';

/// 展开重复事件到指定日期范围内的所有出现日期
List<DateTime> expandRecurrence(
  CalendarEvent event,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  if (event.recurrenceRule == null) {
    // 非重复事件：检查是否在范围内
    final eventStart = DateTime.parse(event.startTime);
    if (!eventStart.isBefore(rangeStart) && eventStart.isBefore(rangeEnd)) {
      return [eventStart];
    }
    return [];
  }

  final startDate = DateTime.parse(event.startTime);
  final rule = event.recurrenceRule!;
  final exceptions = <String>{};
  if (event.recurrenceException != null) {
    for (final d in event.recurrenceException!) {
      exceptions.add(d.split('T').first);
    }
  }

  final dates = <DateTime>[];
  var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
  var count = 0;
  const maxIterations = 1000;

  while (currentDate.isBefore(rangeEnd) && count < maxIterations) {
    if (!currentDate.isBefore(rangeStart)) {
      final dateStr = _toIsoDate(currentDate);
      if (!exceptions.contains(dateStr)) {
        dates.add(currentDate);
      }
    }

    // 移动到下一个出现
    switch (rule.frequency) {
      case 'daily':
        currentDate = currentDate.add(Duration(days: rule.interval));
        break;
      case 'weekly':
        currentDate = currentDate.add(Duration(days: 7 * rule.interval));
        break;
      case 'monthly':
        currentDate = DateTime(
          currentDate.year,
          currentDate.month + rule.interval,
          currentDate.day,
        );
        break;
      case 'yearly':
        currentDate = DateTime(
          currentDate.year + rule.interval,
          currentDate.month,
          currentDate.day,
        );
        break;
    }

    // 检查结束条件
    if (rule.endDate != null &&
        currentDate.isAfter(DateTime.parse(rule.endDate!))) {
      break;
    }
    if (rule.count != null && dates.length >= rule.count!) break;

    count++;
  }

  return dates;
}

/// 获取重复事件在给定日期后的下一次出现
DateTime? getNextOccurrence(CalendarEvent event, DateTime after) {
  if (event.recurrenceRule == null) return null;
  final occurrences = expandRecurrence(
    event,
    after,
    after.add(const Duration(days: 365)),
  );
  return occurrences.isNotEmpty ? occurrences.first : null;
}

/// 检查指定日期是否是重复事件的例外
bool isRecurrenceException(CalendarEvent event, DateTime date) {
  if (event.recurrenceException == null) return false;
  final dateStr = _toIsoDate(date);
  return event.recurrenceException!.contains(dateStr);
}

/// 生成重复规则的中文描述
String describeRecurrence(RecurrenceRule rule) {
  const freqNames = {
    'daily': '天',
    'weekly': '周',
    'monthly': '月',
    'yearly': '年',
  };

  var description =
      '每${rule.interval > 1 ? rule.interval : ''}${freqNames[rule.frequency]}';

  if (rule.byDay != null && rule.frequency == 'weekly') {
    const dayNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    final days = rule.byDay!.map((d) => dayNames[d]).join('、');
    description += '的$days';
  }

  if (rule.endDate != null) {
    final endDate = DateTime.parse(rule.endDate!);
    description += '，直到${endDate.year}年${endDate.month}月${endDate.day}日';
  } else if (rule.count != null) {
    description += '，共${rule.count}次';
  }

  return description;
}

/// 获取指定日期范围内所有事件的出现，按日期分组
Map<String, List<CalendarEvent>> getEventOccurrencesInRange(
  List<CalendarEvent> events,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final occurrences = <String, List<CalendarEvent>>{};

  for (final event in events) {
    final dates = expandRecurrence(event, rangeStart, rangeEnd);
    for (final date in dates) {
      final dateStr = _toIsoDate(date);
      occurrences.putIfAbsent(dateStr, () => []).add(event);
    }
  }

  return occurrences;
}

String _toIsoDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
