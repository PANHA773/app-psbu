import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to {
    if (Get.isRegistered<ThemeController>()) {
      return Get.find<ThemeController>();
    }
    return Get.put(ThemeController(), permanent: true);
  }

  static const _darkModeKey = 'isDarkMode';

  // Cache the SharedPreferences instance to avoid repeated async lookups
  SharedPreferences? _prefs;

  final RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      _isDarkMode.value = _prefs!.getBool(_darkModeKey) ?? false;
      _applyTheme();
    } catch (e) {
      debugPrint('Failed to load theme: $e');
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _saveTheme();
    _applyTheme();
  }

  /// Set dark mode explicitly
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode.value == value) return; // Skip if no change
    _isDarkMode.value = value;
    await _saveTheme();
    _applyTheme();
  }

  /// Save theme to SharedPreferences
  Future<void> _saveTheme() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setBool(_darkModeKey, _isDarkMode.value);
    } catch (e) {
      debugPrint('Failed to save theme: $e');
    }
  }

  /// Apply the current theme to the app
  void _applyTheme() {
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
