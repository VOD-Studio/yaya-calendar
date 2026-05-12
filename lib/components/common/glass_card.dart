// 毛玻璃卡片组件
// 对应原项目的 components/common/GlassCard.tsx

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 毛玻璃效果卡片
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x991E293B)
                  : const Color(0x99FFFFFF),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: colors.border),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
