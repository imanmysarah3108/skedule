// providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

class FontProvider with ChangeNotifier {
  double _fontSize = 16;
  String _fontFamily = 'Roboto';

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }
}