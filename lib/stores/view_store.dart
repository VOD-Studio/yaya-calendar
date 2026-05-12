// 视图状态管理 — 管理日历视图切换和导航
// 对应原项目的 stores/eventStore.ts 中的 ViewState 部分

import 'package:flutter/material.dart';
import 'package:yaya_calendar/domain/types.dart';

/// 视图状态管理器
class ViewStore extends ChangeNotifier {
  ViewType _currentView = ViewType.month;
  String _selectedDate = _todayString();
  String _displayMonth = _monthStartString();
  bool _hasNavigatedMonth = false;

  ViewType get currentView => _currentView;
  String get selectedDate => _selectedDate;
  String get displayMonth => _displayMonth;
  bool get hasNavigatedMonth => _hasNavigatedMonth;

  /// 设置当前视图
  void setCurrentView(ViewType view) {
    _currentView = view;
    notifyListeners();
  }

  /// 设置选中日期
  void setSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// 同时设置选中日期和显示月份
  void setSelectedDateAndMonth(String date) {
    final parts = date.split('-');
    final monthStart = '${parts[0]}-${parts[1]}-01';
    _selectedDate = date;
    _displayMonth = monthStart;
    notifyListeners();
  }

  /// 设置显示月份
  void setDisplayMonth(String date) {
    _displayMonth = date;
    notifyListeners();
  }

  /// 设置是否导航过月份
  void setHasNavigatedMonth(bool value) {
    _hasNavigatedMonth = value;
    notifyListeners();
  }

  /// 跳转到今天
  void goToToday() {
    _selectedDate = _todayString();
    _displayMonth = _monthStartString();
    _hasNavigatedMonth = false;
    notifyListeners();
  }

  /// 向前导航
  void goToPrevious() {
    final date = DateTime.parse(_selectedDate);
    DateTime newDate;

    switch (_currentView) {
      case ViewType.year:
        newDate = DateTime(date.year - 1, date.month, date.day);
        break;
      case ViewType.day:
        newDate = date.subtract(const Duration(days: 1));
        break;
      case ViewType.week:
        newDate = date.subtract(const Duration(days: 7));
        break;
      case ViewType.month:
      case ViewType.events:
        newDate = DateTime(date.year, date.month - 1, date.day);
        break;
    }

    _selectedDate = _toIsoDate(newDate);
    notifyListeners();
  }

  /// 向后导航
  void goToNext() {
    final date = DateTime.parse(_selectedDate);
    DateTime newDate;

    switch (_currentView) {
      case ViewType.year:
        newDate = DateTime(date.year + 1, date.month, date.day);
        break;
      case ViewType.day:
        newDate = date.add(const Duration(days: 1));
        break;
      case ViewType.week:
        newDate = date.add(const Duration(days: 7));
        break;
      case ViewType.month:
      case ViewType.events:
        newDate = DateTime(date.year, date.month + 1, date.day);
        break;
    }

    _selectedDate = _toIsoDate(newDate);
    notifyListeners();
  }

  // 静态 helper
  static String _todayString() => _toIsoDate(DateTime.now());
  static String _monthStartString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-01';
  }

  static String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
