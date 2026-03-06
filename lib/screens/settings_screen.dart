import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListTile(
        title: const Text('Темная тема'),
        trailing: Switch(
          value: isDarkMode,
          onChanged: onThemeChanged,
        ),
      ),
    );
  }
}