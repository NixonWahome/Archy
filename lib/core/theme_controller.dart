import 'package:flutter/material.dart';

/// App-wide light/dark theme state. Provided at the root so any screen can read
/// or toggle it without threading `isDarkMode` through every constructor.
class ThemeController extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDark(bool value) {
    if (value == _isDark) return;
    _isDark = value;
    notifyListeners();
  }
}
