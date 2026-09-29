import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final StorageService _storageService = StorageService();

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final mode = await _storageService.getThemeMode();
    if (mode == 'light') _themeMode = ThemeMode.light;
    else if (mode == 'dark') _themeMode = ThemeMode.dark;
    else _themeMode = ThemeMode.system;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';

    _storageService.saveThemeMode(modeString);
    notifyListeners();
  }
}