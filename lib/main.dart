import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens/calendar_screen/calendar_screen.dart';
import 'screens/input_screen/input_screen.dart';
import 'screens/report_screen/report_screen.dart';
import 'screens/setting_screen/setting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'), // ✅ mặc định Tiếng Việt
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "So Thu Chi",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // tạo widget theo index (tránh lỗi layout)
  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const CalendarScreen();
      case 1:
        return const InputScreen();
      case 2:
        return const ReportScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const CalendarScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale; 
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("appTitle".tr())),
      ),
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: "calendar".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: "input".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: "report".tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: "settings".tr(),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
