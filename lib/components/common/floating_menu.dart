// 浮动菜单组件 — 设置、主题切换、关于
// 对应原项目的 components/common/FloatingMenu.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/stores/theme_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 浮动菜单
class FloatingMenu extends StatelessWidget {
  final bool visible;
  final VoidCallback onClose;

  const FloatingMenu({super.key, required this.visible, required this.onClose});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final colors = getColors(context);
    final themeStore = context.read<ThemeStore>();

    return Stack(
      children: [
        // 背景遮罩
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),
        // 菜单面板
        Positioned(
          left: 16,
          bottom: MediaQuery.of(context).padding.bottom + 88,
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: '设置',
                    colors: colors,
                    onTap: onClose,
                  ),
                  _MenuItem(
                    icon: _themeIcon(themeStore),
                    label: _themeLabel(themeStore),
                    colors: colors,
                    onTap: () {
                      themeStore.toggleTheme();
                      onClose();
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    label: '关于',
                    colors: colors,
                    showDivider: false,
                    onTap: onClose,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _themeIcon(ThemeStore store) {
    if (store.mode == ThemeMode.light) return Icons.light_mode_outlined;
    if (store.mode == ThemeMode.dark) return Icons.dark_mode_outlined;
    return Icons.phone_iphone_outlined;
  }

  String _themeLabel(ThemeStore store) {
    if (store.mode == ThemeMode.light) return '主题: 浅色';
    if (store.mode == ThemeMode.dark) return '主题: 深色';
    return '主题: 跟随系统';
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: colors.text),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 16, color: colors.text),
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
              ],
            ),
          ),
          if (showDivider)
            Divider(height: 1, indent: 16, endIndent: 16, color: colors.border),
        ],
      ),
    );
  }
}
