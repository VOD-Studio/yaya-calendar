// 主页面 — 组装所有日历视图和导航组件，含月↔年缩放过渡动画
// 对应原项目的 app/(main)/index.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/components/calendar/day_view.dart';
import 'package:yaya_calendar/components/calendar/month_view.dart';
import 'package:yaya_calendar/components/calendar/schedule_view.dart';
import 'package:yaya_calendar/components/calendar/year_view.dart';
import 'package:yaya_calendar/components/common/app_modal.dart';
import 'package:yaya_calendar/components/common/calendar_header.dart';
import 'package:yaya_calendar/components/common/floating_menu.dart';
import 'package:yaya_calendar/components/common/floating_nav_bar.dart';
import 'package:yaya_calendar/components/forms/event_form.dart';
import 'package:yaya_calendar/domain/types.dart';
import 'package:yaya_calendar/stores/view_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

const _animDuration = Duration(milliseconds: 300);
const _animCurve = Curves.easeInOut;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  bool _menuVisible = false;

  // 动画控制器
  late AnimationController _transitionController;
  late Animation<double> _animation;

  // 缩放中心偏移量（相对于内容区中心）
  double _originX = 0;
  double _originY = 0;

  // 缩放比例：月视图缩到多小 / 年视图从多小开始
  double _monthTargetScale = 0.33;
  double _yearStartScale = 3.0;

  // 过渡方向：true = 月→年，false = 年→月
  bool _transitioningToYear = true;

  // 内容区尺寸
  Size _contentSize = Size.zero;

  // 是否显示年视图（动画完成后才卸载）
  bool _yearMounted = false;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: _animDuration,
    );
    _animation = CurvedAnimation(
      parent: _transitionController,
      curve: _animCurve,
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final viewStore = context.watch<ViewStore>();
    final currentView = viewStore.currentView;
    final showCalendarLayers =
        currentView == ViewType.month || currentView == ViewType.year;

    final activeTab = currentView == ViewType.events
        ? NavTab.todo
        : NavTab.calendar;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // 主内容区域
          Column(
            children: [
              if (showCalendarLayers)
                CalendarHeader(
                  onYearViewPress: () =>
                      _handleYearToggle(currentView, viewStore),
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _contentSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return showCalendarLayers
                        ? _buildCalendarLayers(currentView, viewStore)
                        : _buildContent(currentView, viewStore);
                  },
                ),
              ),
            ],
          ),

          FloatingNavBar(
            onMenuPress: () => setState(() => _menuVisible = !_menuVisible),
            onAddPress: _showCreateEventSheet,
            activeTab: activeTab,
            onTabChange: (tab) {
              _transitionController.reset();
              _yearMounted = false;
              if (tab == NavTab.calendar) {
                viewStore.setCurrentView(ViewType.month);
              } else {
                viewStore.setCurrentView(ViewType.events);
              }
            },
            menuOpen: _menuVisible,
            onTodayPress: () => viewStore.goToToday(),
            showTodayButton: _shouldShowTodayButton(viewStore),
          ),

          FloatingMenu(
            visible: _menuVisible,
            onClose: () => setState(() => _menuVisible = false),
          ),
        ],
      ),
    );
  }

  /// 月/年切换按钮
  void _handleYearToggle(ViewType currentView, ViewStore viewStore) {
    if (currentView == ViewType.month) {
      _animateToYear(viewStore);
    } else {
      final month = DateTime.parse(viewStore.selectedDate).month;
      _animateToMonth(month);
    }
  }

  /// 月→年动画
  void _animateToYear(ViewStore viewStore) {
    final month = DateTime.parse(viewStore.selectedDate).month;
    _setupTransitionOrigin(month);
    _transitioningToYear = true;

    setState(() => _yearMounted = true);

    // 切换视图状态，让 IgnorePointer 和 CalendarHeader 正确响应
    viewStore.setCurrentView(ViewType.year);

    _transitionController.forward(from: 0).then((_) {
      if (!mounted) return;
    });
  }

  /// 年→月动画，[month] 是点击的月份（1-12）
  void _animateToMonth(int month) {
    _setupTransitionOrigin(month);
    _transitioningToYear = false;

    _transitionController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() => _yearMounted = false);
    });
  }

  /// 根据月份计算缩放中心
  void _setupTransitionOrigin(int month) {
    if (_contentSize.width == 0 || _contentSize.height == 0) return;

    // 年网格 3列×4行
    final col = (month - 1) % 3;
    final row = (month - 1) ~/ 3;

    final cellWidth = _contentSize.width / 3;
    final cellHeight = _contentSize.height / 4;

    final cellCenterX = (col + 0.5) * cellWidth;
    final cellCenterY = (row + 0.5) * cellHeight;

    _originX = cellCenterX - _contentSize.width / 2;
    _originY = cellCenterY - _contentSize.height / 2;

    _monthTargetScale = cellWidth / _contentSize.width;
    _yearStartScale = 1 / _monthTargetScale;
  }

  /// 叠放月/年视图并应用动画变换
  Widget _buildCalendarLayers(ViewType currentView, ViewStore viewStore) {
    final isAnimating =
        _transitionController.isAnimating ||
        _transitionController.status == AnimationStatus.completed;

    final showMonth = currentView == ViewType.month || isAnimating;
    final showYear =
        currentView == ViewType.year || (isAnimating && _yearMounted);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;

        // 月→年：monthScale 1→cellScale, monthOpacity 1→0
        // 年→月：monthScale cellScale→1, monthOpacity 0→1
        final monthScale = _transitioningToYear
            ? 1.0 - (1.0 - _monthTargetScale) * t
            : _monthTargetScale + (1.0 - _monthTargetScale) * t;
        final monthOpacity = _transitioningToYear ? 1.0 - t : t;

        final yearScale = _transitioningToYear
            ? _yearStartScale - (_yearStartScale - 1.0) * t
            : 1.0 + (_yearStartScale - 1.0) * t;
        final yearOpacity = _transitioningToYear ? t : 1.0 - t;

        return Stack(
          children: [
            // 年图层
            if (showYear || _yearMounted)
              IgnorePointer(
                ignoring: currentView != ViewType.year,
                child: Opacity(
                  opacity: yearOpacity.clamp(0.0, 1.0),
                  child: _buildSandwichTransform(
                    scale: yearScale,
                    child: YearView(
                      displayYear: DateTime.parse(viewStore.displayMonth).year,
                      onMonthPress: (month) {
                        _animateToMonth(month);
                      },
                    ),
                  ),
                ),
              ),

            // 月图层
            if (showMonth)
              IgnorePointer(
                ignoring: currentView != ViewType.month,
                child: Opacity(
                  opacity: monthOpacity.clamp(0.0, 1.0),
                  child: _buildSandwichTransform(
                    scale: monthScale,
                    child: const MonthView(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(ViewType currentView, ViewStore viewStore) {
    switch (currentView) {
      case ViewType.month:
        return const MonthView();
      case ViewType.year:
        return YearView(
          displayYear: DateTime.parse(viewStore.displayMonth).year,
        );
      case ViewType.day:
      case ViewType.week:
        return const DayView();
      case ViewType.events:
        return const ScheduleView();
    }
  }

  /// 三明治变换：translate(dx,dy) → scale → translate(-dx,-dy)
  /// 让缩放以 (center + origin) 为锚点
  Widget _buildSandwichTransform({
    required double scale,
    required Widget child,
  }) {
    final dx = _originX * (scale - 1);
    final dy = _originY * (scale - 1);
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.scale(
        scale: scale,
        child: Transform.translate(offset: Offset(-dx, -dy), child: child),
      ),
    );
  }

  bool _shouldShowTodayButton(ViewStore viewStore) {
    final now = DateTime.now();
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final displayMonth = DateTime.parse(viewStore.displayMonth);
    return viewStore.selectedDate != todayStr ||
        displayMonth.year != now.year ||
        displayMonth.month != now.month;
  }

  void _showCreateEventSheet() {
    final viewStore = context.read<ViewStore>();
    AppModal.show(
      context: context,
      title: '新建事件',
      child: EventForm(
        initialDate: viewStore.selectedDate,
        onSave: () => Navigator.of(context).pop(),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
