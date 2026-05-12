// 主页面 — 组装所有日历视图和导航组件
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _menuVisible = false;

  @override
  Widget build(BuildContext context) {
    final colors = getColors(context);
    final viewStore = context.watch<ViewStore>();
    final currentView = viewStore.currentView;

    final activeTab =
        currentView == ViewType.events ? NavTab.todo : NavTab.calendar;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // 主内容区域
          Column(
            children: [
              // 日历头部（仅在月/年视图显示）
              if (currentView == ViewType.month || currentView == ViewType.year)
                CalendarHeader(
                  onYearViewPress: () {
                    if (currentView == ViewType.month) {
                      viewStore.setCurrentView(ViewType.year);
                    } else {
                      viewStore.setCurrentView(ViewType.month);
                    }
                  },
                ),
              // 视图内容
              Expanded(
                child: _buildContent(currentView, viewStore),
              ),
            ],
          ),

          // 浮动导航栏（Positioned 定位）
          FloatingNavBar(
            onMenuPress: () => setState(() => _menuVisible = !_menuVisible),
            onAddPress: _showCreateEventSheet,
            activeTab: activeTab,
            onTabChange: (tab) {
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

          // 浮动菜单
          FloatingMenu(
            visible: _menuVisible,
            onClose: () => setState(() => _menuVisible = false),
          ),
        ],
      ),
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
