import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _localeKey = 'locale';
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale khmerLocale = Locale('km', 'KH');

  final Rx<Locale> locale = englishLocale.obs;

  @override
  void onInit() {
    super.onInit();
    locale.value = Get.locale ?? englishLocale;
  }

  static Future<Locale> getInitialLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_localeKey);
    if (value == 'km_KH') return khmerLocale;
    return englishLocale;
  }

  Future<void> setLanguage(Locale newLocale) async {
    if (locale.value == newLocale) return;
    locale.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _toStorage(newLocale));
    Get.updateLocale(newLocale);
  }

  bool get isKhmer => locale.value.languageCode == 'km';
  String get currentLanguageLabel => isKhmer ? 'ខ្មែរ' : 'English (US)';

  static String _toStorage(Locale locale) =>
      '${locale.languageCode}_${locale.countryCode ?? ''}';
}
