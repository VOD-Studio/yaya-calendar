// 农历服务层 — 封装 lunar 包，提供项目所需的农历 API
// 对应原项目的 domain/lunar.ts

import 'package:lunar/lunar.dart' as lunar_lib;
import 'package:yaya_calendar/domain/types.dart';

// 二十四节气顺序
const List<String> _solarTerms = [
  '小寒', '大寒', '立春', '雨水', '惊蛰', '春分',
  '清明', '谷雨', '立夏', '小满', '芒种', '夏至',
  '小暑', '大暑', '立秋', '处暑', '白露', '秋分',
  '寒露', '霜降', '立冬', '小雪', '大雪', '冬至',
];

// 传统节日（休息日）
const Set<String> _traditionalHolidays = {
  '春节', '元宵节', '清明节', '端午节', '中秋节', '重阳节', '除夕',
};

// 法定假日
const Set<String> _statutoryHolidays = {
  '元旦', '春节', '清明节', '劳动节', '端午节', '中秋节', '国庆节',
};

// 农历信息月级缓存
final Map<String, Map<String, LunarInfo>> _lunarMonthCache = {};

/// 清除农历缓存
void clearLunarCache() {
  _lunarMonthCache.clear();
}

/// 将公历日期转为农历日期
LunarDate toLunarDate(DateTime date) {
  final solar = lunar_lib.Solar.fromDate(date);
  final lunar = solar.getLunar();

  return LunarDate(
    year: lunar.getYear(),
    month: lunar.getMonth(),
    day: lunar.getDay(),
    isLeapMonth: lunar.getMonth() < 0,
    monthName: lunar.getMonthInChinese(),
    dayName: lunar.getDayInChinese(),
    yearGanZhi: '${lunar.getYearGan()}${lunar.getYearZhi()}年',
    monthGanZhi: '${lunar.getMonthGan()}${lunar.getMonthZhi()}',
    dayGanZhi: '${lunar.getDayGan()}${lunar.getDayZhi()}',
    yearShengXiao: '${lunar.getYearShengXiao()}年',
  );
}

/// 获取农历日显示文字
/// 初一显示月名，其他显示日名
String getLunarDayDisplay(DateTime date) {
  final lunar = toLunarDate(date);
  if (lunar.day == 1) return lunar.monthName;
  return lunar.dayName;
}

/// 获取指定日期的节气（如果有）
SolarTerm? getSolarTerm(DateTime date) {
  final solar = lunar_lib.Solar.fromDate(date);
  final lunar = solar.getLunar();
  final jieQi = lunar.getJieQi();

  if (jieQi.isNotEmpty) {
    return SolarTerm(
      name: jieQi,
      date: _toIsoDate(date),
      index: _solarTerms.indexOf(jieQi),
    );
  }
  return null;
}

/// 获取指定日期的所有节日
List<Holiday> getHolidays(DateTime date) {
  final solar = lunar_lib.Solar.fromDate(date);
  final lunar = solar.getLunar();
  final result = <Holiday>[];
  final dateStr = _toIsoDate(date);

  // 农历节日
  final lunarFestivals = lunar.getFestivals();
  for (final f in lunarFestivals) {
    result.add(Holiday(
      name: f,
      date: dateStr,
      type: 'traditional',
      isHoliday: _traditionalHolidays.contains(f),
    ));
  }

  // 公历节日
  final solarFestivals = solar.getFestivals();
  for (final f in solarFestivals) {
    result.add(Holiday(
      name: f,
      date: dateStr,
      type: 'statutory',
      isHoliday: _statutoryHolidays.contains(f),
    ));
  }

  // 节气
  final jieQi = lunar.getJieQi();
  if (jieQi.isNotEmpty) {
    result.add(Holiday(
      name: jieQi,
      date: dateStr,
      type: 'solar_term',
      isHoliday: false,
    ));
  }

  return result;
}

/// 是否是假日
bool isHoliday(DateTime date) {
  return getHolidays(date).any((h) => h.isHoliday);
}

/// 是否是节气日
bool isSolarTermDay(DateTime date) {
  final solar = lunar_lib.Solar.fromDate(date);
  final lunar = solar.getLunar();
  final jq = lunar.getJieQi();
  return jq.isNotEmpty;
}

/// 获取主要节日/节气显示名称
String? getHolidayDisplay(DateTime date) {
  final holidays = getHolidays(date);
  // 优先显示传统节日和法定假日
  final priorityHolidays = holidays.where((h) => h.type != 'solar_term').toList();
  if (priorityHolidays.isNotEmpty) return priorityHolidays.first.name;
  // 其次显示节气
  final solarTermHoliday = holidays.where((h) => h.type == 'solar_term').firstOrNull;
  return solarTermHoliday?.name;
}

/// 获取综合农历信息（用于日历格子显示）
LunarInfo getLunarInfo(DateTime date) {
  final lunarDay = getLunarDayDisplay(date);
  final solarTerm = getSolarTerm(date);
  final holiday = getHolidayDisplay(date);
  final isHolidayDay = isHoliday(date);
  final isSolarTermDayFlag = isSolarTermDay(date);

  return LunarInfo(
    lunarDay: lunarDay,
    solarTerm: solarTerm?.name,
    holiday: holiday,
    isHoliday: isHolidayDay,
    isSolarTerm: isSolarTermDayFlag,
  );
}

/// 批量获取整月的农历信息（带缓存）
Map<String, LunarInfo> getLunarInfoBatch(int year, int month) {
  final cacheKey = '$year-${month.toString().padLeft(2, '0')}';

  if (_lunarMonthCache.containsKey(cacheKey)) {
    return _lunarMonthCache[cacheKey]!;
  }

  final result = <String, LunarInfo>{};
  final days = _getMonthCalendarDays(year, month);

  for (final day in days) {
    final dateStr = _toIsoDate(day);
    result[dateStr] = getLunarInfo(day);
  }

  // LRU 淘汰
  if (_lunarMonthCache.length >= 12) {
    _lunarMonthCache.remove(_lunarMonthCache.keys.first);
  }
  _lunarMonthCache[cacheKey] = result;
  return result;
}

/// 获取干支信息
({String year, String month, String day}) getGanZhi(DateTime date) {
  final lunar = toLunarDate(date);
  return (
    year: lunar.yearGanZhi,
    month: lunar.monthGanZhi,
    day: lunar.dayGanZhi,
  );
}

// ============================================================================
// 内部 helper
// ============================================================================

/// 获取月历范围的所有日期（周一开始）
List<DateTime> _getMonthCalendarDays(int year, int month) {
  final monthStart = DateTime(year, month, 1);
  final monthEnd = DateTime(year, month + 1, 0);

  final calStart = _mondayOfWeek(monthStart);
  final calEnd = _sundayOfWeek(monthEnd);

  final days = <DateTime>[];
  for (var d = calStart;
      !d.isAfter(calEnd);
      d = d.add(const Duration(days: 1))) {
    days.add(d);
  }
  return days;
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
