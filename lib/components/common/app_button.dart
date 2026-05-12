// 通用按钮组件
// 对应原项目的 components/common/Button.tsx

import 'package:flutter/material.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 应用按钮变体
enum ButtonVariant { primary, secondary, ghost, danger }

/// 应用按钮大小
enum ButtonSize { sm, md, lg }

/// 通用按钮组件
class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final bool loading;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.disabled = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final bgColor = _getBackgroundColor(colors);
    final textColor = _getTextColor(colors);
    final sizeData = _getSizeData();

    return SizedBox(
      height: sizeData.height,
      child: ElevatedButton(
        onPressed: (disabled || loading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: sizeData.paddingH,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: variant == ButtonVariant.secondary
                ? BorderSide(color: colors.border)
                : BorderSide.none,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: sizeData.fontSize,
                ),
              ),
      ),
    );
  }

  Color _getBackgroundColor(AppColors colors) {
    if (disabled) return colors.surfaceVariant;
    switch (variant) {
      case ButtonVariant.primary:
        return colors.primary;
      case ButtonVariant.secondary:
        return colors.surface;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.danger:
        return colors.error;
    }
  }

  Color _getTextColor(AppColors colors) {
    if (disabled) return colors.textTertiary;
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return colors.text;
      case ButtonVariant.ghost:
        return colors.primary;
      case ButtonVariant.danger:
        return Colors.white;
    }
  }

  ({double fontSize, double paddingH, double height}) _getSizeData() {
    switch (size) {
      case ButtonSize.sm:
        return (fontSize: 14.0, paddingH: 12.0, height: 36.0);
      case ButtonSize.md:
        return (fontSize: 16.0, paddingH: 16.0, height: 44.0);
      case ButtonSize.lg:
        return (fontSize: 18.0, paddingH: 24.0, height: 52.0);
    }
  }
}
