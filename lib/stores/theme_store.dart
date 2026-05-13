// 主题状态管理 — 支持亮色/暗色/跟随系统
// 对应原项目的 stores/themeStore.tsx

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 主题状态管理器
class ThemeStore extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeData _themeData = buildLightTheme();

  ThemeStore() {
    _loadFromPrefs();
  }

  ThemeMode get mode => _mode;
  ThemeData get themeData => _themeData;
  bool get isDark => _themeData.brightness == Brightness.dark;

  /// 设置主题模式
  void setMode(ThemeMode newMode) {
    _mode = newMode;
    _updateTheme();
    _saveToPrefs();
    notifyListeners();
  }

  /// 切换亮色/暗色
  void toggleTheme() {
    final effectiveMode = _getEffectiveMode();
    final newMode = effectiveMode == Brightness.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setMode(newMode);
  }

  /// 根据系统主题变化更新（在 App 层调用）
  void onSystemThemeChanged(Brightness platformBrightness) {
    if (_mode == ThemeMode.system) {
      _updateTheme();
      notifyListeners();
    }
  }

  /// 获取当前有效的亮度
  Brightness _getEffectiveMode() {
    if (_mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
    return _mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  void _updateTheme() {
    final effective = _getEffectiveMode();
    _themeData = effective == Brightness.dark
        ? buildDarkTheme()
        : buildLightTheme();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('yaya-theme-mode');
    if (saved != null) {
      switch (saved) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        default:
          _mode = ThemeMode.system;
      }
      _updateTheme();
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = _mode == ThemeMode.light
        ? 'light'
        : _mode == ThemeMode.dark
        ? 'dark'
        : 'system';
    await prefs.setString('yaya-theme-mode', value);
  }
}
