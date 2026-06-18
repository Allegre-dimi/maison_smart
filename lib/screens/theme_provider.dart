import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère le thème de l'app — par défaut dark (style premium).
///
/// API rétrocompatible : `isDarkMode` + `toggleTheme()` continuent de marcher.
/// Nouveautés : `themeMode` pour MaterialApp + persistance via SharedPreferences.
class ThemeProvider extends ChangeNotifier {
  static const _kKey = 'ndako.themeMode';

  // Démarre en dark par défaut — palette pensée pour le dark premium.
  bool _isDarkMode = true;
  bool _loaded = false;

  ThemeProvider() {
    _restore();
  }

  bool get isDarkMode => _isDarkMode;
  bool get loaded => _loaded;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_kKey);
      if (v == 'light') _isDarkMode = false;
      if (v == 'dark') _isDarkMode = true;
    } catch (_) {}
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kKey, _isDarkMode ? 'dark' : 'light');
    } catch (_) {}
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _persist();
  }

  void setDark(bool dark) {
    if (_isDarkMode == dark) return;
    _isDarkMode = dark;
    notifyListeners();
    _persist();
  }
}
