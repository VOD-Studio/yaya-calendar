// 事件状态管理 — 管理事件数据和视图状态
// 对应原项目的 stores/eventStore.ts

import 'package:flutter/material.dart';
import 'package:yaya_calendar/domain/recurrence.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/services/database.dart';

/// 事件状态管理器
class EventStore extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<CalendarEvent> _events = [];
  bool _loading = false;
  String? _error;
  String? _selectedEventId;

  // 月级事件缓存
  final Map<String, Map<String, List<CalendarEvent>>> _monthCache = {};

  List<CalendarEvent> get events => _events;
  bool get loading => _loading;
  String? get error => _error;
  String? get selectedEventId => _selectedEventId;

  /// 加载所有事件
  Future<void> loadEvents() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _db.init();
      _events = await _db.getAllEvents();
      _monthCache.clear();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  /// 创建事件
  Future<CalendarEvent> createEvent(Map<String, dynamic> eventData) async {
    _loading = true;
    notifyListeners();
    try {
      final event = await _db.createEvent(eventData);
      _monthCache.clear();
      _events = [..._events, event];
      _loading = false;
      notifyListeners();
      return event;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 更新事件
  Future<CalendarEvent> updateEvent(
    String id,
    Map<String, dynamic> updates,
  ) async {
    _loading = true;
    notifyListeners();
    try {
      final event = await _db.updateEvent(id, updates);
      _monthCache.clear();
      _events = _events.map((e) => e.id == id ? event : e).toList();
      _loading = false;
      notifyListeners();
      return event;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 删除事件
  Future<void> deleteEvent(String id) async {
    _loading = true;
    notifyListeners();
    try {
      await _db.deleteEvent(id);
      _monthCache.clear();
      _events = _events.where((e) => e.id != id).toList();
      if (_selectedEventId == id) _selectedEventId = null;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 选中事件
  void selectEvent(String? id) {
    _selectedEventId = id;
    notifyListeners();
  }

  /// 根据 ID 获取事件
  CalendarEvent? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 获取指定日期的事件
  List<CalendarEvent> getEventsForDate(String date) {
    final dateStart = DateTime.parse(date);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final eventsForDate = <CalendarEvent>[];
    for (final event in _events) {
      final occurrences = expandRecurrence(event, dateStart, dateEnd);
      if (occurrences.isNotEmpty) {
        eventsForDate.add(event);
      }
    }
    eventsForDate.sort((a, b) => a.startTime.compareTo(b.startTime));
    return eventsForDate;
  }

  /// 获取指定月份的事件（带缓存）
  Map<String, List<CalendarEvent>> getEventsForMonth(int year, int month) {
    final cacheKey = '$year-$month';
    if (_monthCache.containsKey(cacheKey)) {
      return _monthCache[cacheKey]!;
    }

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = getEventOccurrencesInRange(_events, monthStart, monthEnd);
    _monthCache[cacheKey] = result;
    return result;
  }

  /// 获取指定日期范围内的事件
  Map<String, List<CalendarEvent>> getEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return getEventOccurrencesInRange(_events, startDate, endDate);
  }
}
