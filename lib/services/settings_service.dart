import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'is_dark_theme';

  Future<bool> isDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}