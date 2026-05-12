// 底部弹出模态框组件
// 对应原项目的 components/common/Modal.tsx

import 'package:flutter/material.dart';
import 'package:yaya_calendar/styles/theme.dart';

/// 底部弹出模态框 — 使用 showModalBottomSheet 的便捷封装
class AppModal {
  /// 显示模态框
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    Widget? footer,
  }) {
    final colors = getColors(context);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            minHeight: 200,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              if (title != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              // 内容区
              Flexible(child: child),
              // 底部操作区
              if (footer != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colors.border),
                    ),
                  ),
                  child: footer,
                ),
            ],
          ),
        );
      },
    );
  }
}
