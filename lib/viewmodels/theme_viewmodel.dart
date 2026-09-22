import 'package:flutter/material.dart';
import 'package:cleansaver/core/theme/app_theme.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeData _themeData = AppTheme.darkTheme;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeData get themeData => _themeData;
  ThemeMode get themeMode => _themeMode;

  // For future light mode support
  void toggleTheme() {
    // Currently dark-only, but extensible
    notifyListeners();
  }
}
