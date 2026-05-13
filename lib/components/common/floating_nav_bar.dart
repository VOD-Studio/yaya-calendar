// 浮动导航栏 — 底部导航控制
// 对应原项目的 components/common/FloatingNavBar.tsx

import 'package:flutter/material.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 导航标签类型
enum NavTab { calendar, todo }

/// 浮动导航栏
class FloatingNavBar extends StatelessWidget {
  final VoidCallback onMenuPress;
  final VoidCallback onAddPress;
  final NavTab activeTab;
  final ValueChanged<NavTab> onTabChange;
  final bool menuOpen;
  final VoidCallback? onTodayPress;
  final bool showTodayButton;

  const FloatingNavBar({
    super.key,
    required this.onMenuPress,
    required this.onAddPress,
    required this.activeTab,
    required this.onTabChange,
    this.menuOpen = false,
    this.onTodayPress,
    this.showTodayButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: (bottomPadding > 8 ? bottomPadding : 8) + 8.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 左侧：菜单按钮
            _CircleButton(
              icon: menuOpen ? Icons.close : Icons.menu,
              backgroundColor: colors.surfaceVariant,
              iconColor: colors.text,
              onPressed: onMenuPress,
            ),
            const Spacer(),
            // 中间：分段控制
            _SegmentedControl(
              activeTab: activeTab,
              onTabChange: onTabChange,
              colors: colors,
            ),
            const Spacer(),
            // 右侧：今天按钮 + 添加按钮
            Stack(
              clipBehavior: Clip.none,
              children: [
                _CircleButton(
                  icon: Icons.add,
                  backgroundColor: colors.primary,
                  iconColor: Colors.white,
                  onPressed: onAddPress,
                  size: 28,
                ),
                // 今天按钮
                if (showTodayButton)
                  Positioned(
                    bottom: 52,
                    right: 0,
                    child: _CircleButton(
                      text: '今',
                      backgroundColor: colors.primary,
                      iconColor: Colors.white,
                      onPressed: onTodayPress ?? () {},
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 圆形按钮
class _CircleButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;
  final double size;

  const _CircleButton({
    this.icon,
    this.text,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Icon(icon, size: size, color: iconColor),
        ),
      ),
    );
  }
}

/// 分段控制器
class _SegmentedControl extends StatelessWidget {
  final NavTab activeTab;
  final ValueChanged<NavTab> onTabChange;
  final AppColors colors;

  const _SegmentedControl({
    required this.activeTab,
    required this.onTabChange,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            label: '日历',
            active: activeTab == NavTab.calendar,
            colors: colors,
            onTap: () => onTabChange(NavTab.calendar),
          ),
          const SizedBox(width: 8),
          _TabItem(
            label: '日程',
            active: activeTab == NavTab.todo,
            colors: colors,
            onTap: () => onTabChange(NavTab.todo),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 80,
        height: 36,
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFFFAFAFA))
                  : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
