// 排班计算工具
// 规则：基准日期 2026-05-07、2026-05-08 是"班"，周期 2天班 + 2天休

import 'package:yaya_calendar/domain/types.dart';

final DateTime _baseDate = DateTime(2026, 5, 7);
const int _cycleDays = 4;

/// 计算给定日期的班休状态
WorkStatus getWorkStatus(DateTime date) {
  final diffDays = DateTime(date.year, date.month, date.day)
      .difference(DateTime(_baseDate.year, _baseDate.month, _baseDate.day))
      .inDays;
  // 处理负数
  final dayInCycle = ((diffDays % _cycleDays) + _cycleDays) % _cycleDays;
  return dayInCycle < 2 ? WorkStatus.work : WorkStatus.rest;
}
