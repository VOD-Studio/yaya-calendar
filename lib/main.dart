// 应用入口 — 初始化 Provider、主题、数据库
// 对应原项目的 app/_layout.tsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaya_calendar/screens/main_screen.dart';
import 'package:yaya_calendar/services/database.dart';
import 'package:yaya_calendar/stores/event_store.dart';
import 'package:yaya_calendar/stores/theme_store.dart';
import 'package:yaya_calendar/stores/view_store.dart';
import 'package:yaya_calendar/styles/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DatabaseService().init();
  } catch (e, s) {
    debugPrint('Database init failed (will use in-memory fallback): $e\n$s');
  }

  final themeStore = ThemeStore();

  runApp(YayaCalendarApp(themeStore: themeStore));
}

class YayaCalendarApp extends StatelessWidget {
  final ThemeStore themeStore;

  const YayaCalendarApp({super.key, required this.themeStore});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeStore),
        ChangeNotifierProvider(create: (_) => ViewStore()),
        ChangeNotifierProvider(
          create: (_) {
            final store = EventStore();
            store.loadEvents();
            return store;
          },
        ),
      ],
      child: Consumer<ThemeStore>(
        builder: (context, themeStore, _) {
          return MaterialApp(
            title: '丫丫日历',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeStore.mode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
