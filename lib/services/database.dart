// 数据库服务 — 移动/桌面使用 sqflite；Web 上退化为内存存储（刷新即丢）
// 对应原项目的 services/database.native.ts

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:yaya_calendar/domain/types.dart';

const _dbName = 'yaya_calendar.db';

/// 数据库服务：提供事件的增删改查操作
class DatabaseService {
  static Database? _db;
  // Web 上的内存存储（按事件 id 索引）
  static final Map<String, Map<String, dynamic>> _memoryRows = {};
  final _uuid = const Uuid();

  /// 获取数据库实例（懒初始化，仅非 Web 平台）
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('sqflite is not available on web');
    }
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE events (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            color TEXT NOT NULL DEFAULT '#6366F1',
            recurrence_rule TEXT,
            recurrence_exception TEXT,
            timezone TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_events_start_time ON events(start_time)',
        );
        await db.execute(
          'CREATE INDEX idx_events_end_time ON events(end_time)',
        );
      },
    );
  }

  /// 初始化数据库连接
  Future<void> init() async {
    if (kIsWeb) return;
    await database;
  }

  /// 创建事件
  Future<CalendarEvent> createEvent(Map<String, dynamic> eventData) async {
    final now = DateTime.now().toIso8601String();
    final event = CalendarEvent(
      id: _uuid.v4(),
      title: eventData['title'] as String,
      description: eventData['description'] as String?,
      startTime: eventData['start_time'] as String,
      endTime: eventData['end_time'] as String,
      color: eventData['color'] as String? ?? '#6366F1',
      recurrenceRule: eventData['recurrence_rule'] != null
          ? RecurrenceRule.fromJson(eventData['recurrence_rule'] as String)
          : null,
      recurrenceException: eventData['recurrence_exception'] != null
          ? (eventData['recurrence_exception'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList()
          : null,
      timezone: eventData['timezone'] as String?,
      createdAt: now,
      updatedAt: now,
    );

    if (kIsWeb) {
      _memoryRows[event.id] = event.toMap();
      return event;
    }

    final db = await database;
    await db.insert('events', event.toMap());
    return event;
  }

  /// 更新事件
  Future<CalendarEvent> updateEvent(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final existing = await getEventById(id);
    if (existing == null) throw Exception('Event not found: $id');

    final now = DateTime.now().toIso8601String();
    final updated = existing.copyWith(
      title: updates['title'] as String?,
      description: updates['description'] as String?,
      startTime: updates['start_time'] as String?,
      endTime: updates['end_time'] as String?,
      color: updates['color'] as String?,
      recurrenceRule: updates['recurrence_rule'] != null
          ? RecurrenceRule.fromJson(updates['recurrence_rule'] as String)
          : null,
      recurrenceException: updates['recurrence_exception'] != null
          ? (updates['recurrence_exception'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList()
          : null,
      timezone: updates['timezone'] as String?,
      updatedAt: now,
    );

    if (kIsWeb) {
      _memoryRows[id] = updated.toMap();
      return updated;
    }

    final db = await database;
    await db.update(
      'events',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    return updated;
  }

  /// 删除事件
  Future<void> deleteEvent(String id) async {
    if (kIsWeb) {
      _memoryRows.remove(id);
      return;
    }
    final db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  /// 根据 ID 获取事件
  Future<CalendarEvent?> getEventById(String id) async {
    if (kIsWeb) {
      final row = _memoryRows[id];
      return row == null ? null : CalendarEvent.fromMap(row);
    }
    final db = await database;
    final rows = await db.query('events', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return CalendarEvent.fromMap(rows.first);
  }

  /// 获取指定日期范围内的事件
  Future<List<CalendarEvent>> getEventsByDateRange(
    String start,
    String end,
  ) async {
    if (kIsWeb) {
      final list =
          _memoryRows.values.where((row) {
            final s = row['start_time'] as String;
            return s.compareTo(start) >= 0 && s.compareTo(end) < 0;
          }).toList()..sort(
            (a, b) => (a['start_time'] as String).compareTo(
              b['start_time'] as String,
            ),
          );
      return list.map(CalendarEvent.fromMap).toList();
    }
    final db = await database;
    final rows = await db.query(
      'events',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [start, end],
      orderBy: 'start_time ASC',
    );
    return rows.map(CalendarEvent.fromMap).toList();
  }

  /// 获取所有事件
  Future<List<CalendarEvent>> getAllEvents() async {
    if (kIsWeb) {
      final list = _memoryRows.values.toList()
        ..sort(
          (a, b) =>
              (a['start_time'] as String).compareTo(b['start_time'] as String),
        );
      return list.map(CalendarEvent.fromMap).toList();
    }
    final db = await database;
    final rows = await db.query('events', orderBy: 'start_time ASC');
    return rows.map(CalendarEvent.fromMap).toList();
  }

  /// 导出数据库为 JSON 字符串
  Future<String> exportDatabase() async {
    final events = await getAllEvents();
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'events': events.map((e) => e.toMap()).toList(),
    };
    return data.toString();
  }
}
