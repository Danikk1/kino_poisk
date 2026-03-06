import 'services/db_init.dart';
import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    initDatabase();
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _settingsService.isDarkTheme();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    await _settingsService.setTheme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мини Кинопоиск',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}