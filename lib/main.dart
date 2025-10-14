import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens/calendar_screen/calendar_screen.dart';
import 'screens/input_screen/input_screen.dart';
import 'screens/report_screen/report_screen.dart';
import 'screens/setting_screen/setting_screen.dart';
import 'package:provider/provider.dart';
import 'screens/input_screen/input_controller.dart';

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
      startLocale: const Locale('vi'), // mặc định Tiếng Việt
      child:MultiProvider( // Bọc bằng MultiProvider
        providers: [
          ChangeNotifierProvider(create: (_) => InputController()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = ThemeData.dark().copyWith(
      // Màu nền chung cho các màn hình
      scaffoldBackgroundColor: Colors.grey.shade900, 
      // Màu cho AppBar và các thanh công cụ khác
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Màu cho Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey.shade800,
        selectedItemColor: Colors.blue.shade300,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
      ),
      // Màu cho các thành phần khác
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade300,
        secondary: Colors.blue.shade300,
      ),
    );

    return MaterialApp(
      title: "So Thu Chi",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: darkTheme,
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
    return Scaffold(
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
        onTap: _onItemTapped,
      ),
    );
  }
}
