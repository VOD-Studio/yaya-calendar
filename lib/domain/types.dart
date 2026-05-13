import 'dart:convert';

// 核心领域类型定义

/// 事件模型
class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final String startTime; // ISO 8601 格式
  final String endTime;
  final String color; // 十六进制颜色码
  final RecurrenceRule? recurrenceRule;
  final List<String>? recurrenceException;
  final String? timezone;
  final String createdAt;
  final String updatedAt;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.recurrenceRule,
    this.recurrenceException,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? startTime,
    String? endTime,
    String? color,
    RecurrenceRule? recurrenceRule,
    List<String>? recurrenceException,
    String? timezone,
    String? createdAt,
    String? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceException: recurrenceException ?? this.recurrenceException,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 从数据库行创建
  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      color: map['color'] as String,
      recurrenceRule: map['recurrence_rule'] != null
          ? RecurrenceRule.fromJson(map['recurrence_rule'] as String)
          : null,
      recurrenceException: map['recurrence_exception'] != null
          ? (map['recurrence_exception'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList()
          : null,
      timezone: map['timezone'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// 转换为数据库行
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'color': color,
      'recurrence_rule': recurrenceRule?.toJson(),
      'recurrence_exception': recurrenceException?.join(','),
      'timezone': timezone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// 重复规则
class RecurrenceRule {
  final String frequency; // "daily" | "weekly" | "monthly" | "yearly"
  final int interval;
  final String? endDate;
  final int? count;
  final List<int>? byDay;
  final int? byMonthDay;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.endDate,
    this.count,
    this.byDay,
    this.byMonthDay,
  });

  factory RecurrenceRule.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return RecurrenceRule(
      frequency: map['frequency'] as String? ?? 'daily',
      interval: map['interval'] as int? ?? 1,
      endDate: map['endDate'] as String?,
      count: map['count'] as int?,
      byDay: map['byDay'] != null ? List<int>.from(map['byDay'] as List) : null,
      byMonthDay: map['byMonthDay'] as int?,
    );
  }

  String toJson() {
    final parts = <String>['"frequency":"$frequency"'];
    parts.add('"interval":$interval');
    if (endDate != null) parts.add('"endDate":"$endDate"');
    if (count != null) parts.add('"count":$count');
    if (byDay != null) parts.add('"byDay":${jsonEncode(byDay)}');
    if (byMonthDay != null) parts.add('"byMonthDay":$byMonthDay');
    return '{${parts.join(',')}}';
  }
}

/// 视图类型
enum ViewType { year, month, week, day, events }

/// 农历日期
class LunarDate {
  final int year;
  final int month; // 农历月（1-12）
  final int day; // 农历日（1-30）
  final bool isLeapMonth;
  final String monthName; // "正月"、"二月"
  final String dayName; // "初一"、"十五"
  final String yearGanZhi; // "甲子年"
  final String monthGanZhi;
  final String dayGanZhi;
  final String yearShengXiao; // "鼠年"

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    required this.isLeapMonth,
    required this.monthName,
    required this.dayName,
    required this.yearGanZhi,
    required this.monthGanZhi,
    required this.dayGanZhi,
    required this.yearShengXiao,
  });
}

/// 节气
class SolarTerm {
  final String name;
  final String date;
  final int index;

  const SolarTerm({
    required this.name,
    required this.date,
    required this.index,
  });
}

/// 节日/假日
class Holiday {
  final String name;
  final String date;
  final String type; // "traditional" | "statutory" | "solar_term"
  final bool isHoliday;
  final bool? isWorkday;

  const Holiday({
    required this.name,
    required this.date,
    required this.type,
    required this.isHoliday,
    this.isWorkday,
  });
}

/// 农历信息缓存（用于日历格子显示）
class LunarInfo {
  final String lunarDay;
  final String? solarTerm;
  final String? holiday;
  final bool isHoliday;
  final bool isSolarTerm;

  const LunarInfo({
    required this.lunarDay,
    this.solarTerm,
    this.holiday,
    required this.isHoliday,
    required this.isSolarTerm,
  });
}

/// 排班状态
enum WorkStatus { work, rest }
