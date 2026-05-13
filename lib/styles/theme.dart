// 主题定义 — 亮色/暗色主题颜色和间距系统
// 对应原项目的 styles/theme.ts

import 'package:flutter/material.dart';

/// 亮色主题颜色
class LightColors {
  static const primary = Color(0xFF8B5CF6); // Violet 500
  static const primaryLight = Color(0xFFA78BFA);
  static const primaryDark = Color(0xFF7C3AED);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFF5F5F5);
  static const surfaceVariant = Color(0xFFEBEBEB);
  static const text = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const todayBackground = Color(0xFFEDE9FE);
  static const todayText = Color(0xFF7C3AED);
  static const selectedBackground = Color(0xFFF3E8FF);
  static const selectedText = Color(0xFF6D28D9);
  static const eventDefault = Color(0xFF8B5CF6);
  static const weekendText = Color(0xFFDC2626);
  static const lunarText = Color(0xFF9CA3AF);
  static const holidayText = Color(0xFFDC2626);
  static const solarTermText = Color(0xFF059669);
}

/// 暗色主题颜色
class DarkColors {
  static const primary = Color(0xFFA78BFA);
  static const primaryLight = Color(0xFFC4B5FD);
  static const primaryDark = Color(0xFF8B5CF6);
  static const background = Color(0xFF1C1C1E);
  static const surface = Color(0xFF2C2C2E);
  static const surfaceVariant = Color(0xFF3A3A3C);
  static const text = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFABABAB);
  static const textTertiary = Color(0xFF6B6B6B);
  static const border = Color(0xFF38383A);
  static const error = Color(0xFFF87171);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const todayBackground = Color(0xFF3B2D5F);
  static const todayText = Color(0xFFC4B5FD);
  static const selectedBackground = Color(0xFF4C3A6E);
  static const selectedText = Color(0xFFDDD6FE);
  static const eventDefault = Color(0xFFA78BFA);
  static const weekendText = Color(0xFFFCA5A5);
  static const lunarText = Color(0xFF6B6B6B);
  static const holidayText = Color(0xFFFCA5A5);
  static const solarTermText = Color(0xFF6EE7B7);
}

/// 间距系统
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

/// 圆角系统
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const full = 9999.0;
}

/// 主题强调色（用于日历的选中/今日状态）
const Color primaryAccent = Color(0xFFE8563A);

/// 构建亮色 ThemeData
ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: LightColors.background,
    colorScheme: const ColorScheme.light(
      primary: LightColors.primary,
      secondary: LightColors.primaryLight,
      surface: LightColors.surface,
      error: LightColors.error,
      onPrimary: Colors.white,
      onSurface: LightColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.background,
      foregroundColor: LightColors.text,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: LightColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    dividerTheme: const DividerThemeData(color: LightColors.border),
  );
}

/// 构建暗色 ThemeData
ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DarkColors.background,
    colorScheme: const ColorScheme.dark(
      primary: DarkColors.primary,
      secondary: DarkColors.primaryLight,
      surface: DarkColors.surface,
      error: DarkColors.error,
      onPrimary: DarkColors.background,
      onSurface: DarkColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.background,
      foregroundColor: DarkColors.text,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: DarkColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    dividerTheme: const DividerThemeData(color: DarkColors.border),
  );
}

/// 根据亮度获取对应的颜色
/// 用于组件中需要根据主题切换的颜色
AppColors getColors(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.fromDark() : AppColors.fromLight();
}

/// 应用颜色集合（方便在组件中使用）
class AppColors {
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color error;
  final Color todayBackground;
  final Color todayText;
  final Color selectedBackground;
  final Color selectedText;
  final Color eventDefault;
  final Color weekendText;
  final Color lunarText;
  final Color holidayText;
  final Color solarTermText;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.error,
    required this.todayBackground,
    required this.todayText,
    required this.selectedBackground,
    required this.selectedText,
    required this.eventDefault,
    required this.weekendText,
    required this.lunarText,
    required this.holidayText,
    required this.solarTermText,
  });

  factory AppColors.fromLight() => const AppColors(
    primary: LightColors.primary,
    primaryLight: LightColors.primaryLight,
    background: LightColors.background,
    surface: LightColors.surface,
    surfaceVariant: LightColors.surfaceVariant,
    text: LightColors.text,
    textSecondary: LightColors.textSecondary,
    textTertiary: LightColors.textTertiary,
    border: LightColors.border,
    error: LightColors.error,
    todayBackground: LightColors.todayBackground,
    todayText: LightColors.todayText,
    selectedBackground: LightColors.selectedBackground,
    selectedText: LightColors.selectedText,
    eventDefault: LightColors.eventDefault,
    weekendText: LightColors.weekendText,
    lunarText: LightColors.lunarText,
    holidayText: LightColors.holidayText,
    solarTermText: LightColors.solarTermText,
  );

  factory AppColors.fromDark() => const AppColors(
    primary: DarkColors.primary,
    primaryLight: DarkColors.primaryLight,
    background: DarkColors.background,
    surface: DarkColors.surface,
    surfaceVariant: DarkColors.surfaceVariant,
    text: DarkColors.text,
    textSecondary: DarkColors.textSecondary,
    textTertiary: DarkColors.textTertiary,
    border: DarkColors.border,
    error: DarkColors.error,
    todayBackground: DarkColors.todayBackground,
    todayText: DarkColors.todayText,
    selectedBackground: DarkColors.selectedBackground,
    selectedText: DarkColors.selectedText,
    eventDefault: DarkColors.eventDefault,
    weekendText: DarkColors.weekendText,
    lunarText: DarkColors.lunarText,
    holidayText: DarkColors.holidayText,
    solarTermText: DarkColors.solarTermText,
  );
}
