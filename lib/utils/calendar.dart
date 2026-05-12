// 日历计算工具

/// 计算指定月份的日历行数（4-6）
int getCalendarRowCount(int year, int month) {
  final monthStart = DateTime(year, month, 1);
  final monthEnd = DateTime(year, month + 1, 0); // 当月最后一天

  // 周一开始
  final calStart = _mondayOfWeek(monthStart);
  final calEnd = _sundayOfWeek(monthEnd);

  final days = calEnd.difference(calStart).inDays + 1;
  return (days / 7).ceil();
}

/// 计算日历网格高度
double calculateGridHeight(int rowCount, double screenWidth) {
  const horizontalMargin = 32.0;
  const rowGap = 24.0;
  final cellWidth = (screenWidth - horizontalMargin) / 7;
  return rowCount * cellWidth + (rowCount - 1) * rowGap;
}

/// 计算单行高度
double calculateSingleRowHeight(double screenWidth) {
  const horizontalMargin = 32.0;
  const rowGap = 24.0;
  final cellWidth = (screenWidth - horizontalMargin) / 7;
  return cellWidth + rowGap;
}

/// 计算日期在日历中的行索引（0-5）
int getRowIndexForDate(DateTime date, int year, int month) {
  final monthStart = DateTime(year, month, 1);
  final monthEnd = DateTime(year, month + 1, 0);
  final calStart = _mondayOfWeek(monthStart);
  final calEnd = _sundayOfWeek(monthEnd);

  final days = calEnd.difference(calStart).inDays + 1;
  final targetDate = DateTime(date.year, date.month, date.day);
  final diff = targetDate.difference(calStart).inDays;

  if (diff < 0) return 0;
  if (diff >= days) return (days / 7).ceil() - 1;
  return diff ~/ 7;
}

/// 获取某月日历范围的所有日期（周一开始）
List<DateTime> getCalendarDays(int year, int month) {
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

/// 获取包含某日期的周的周一
DateTime _mondayOfWeek(DateTime date) {
  final weekday = date.weekday; // 1=周一, 7=周日
  return date.subtract(Duration(days: weekday - 1));
}

/// 获取包含某日期的周日
DateTime _sundayOfWeek(DateTime date) {
  final weekday = date.weekday;
  return date.add(Duration(days: 7 - weekday));
}
