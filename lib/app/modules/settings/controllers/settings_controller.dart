import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/language_controller.dart';

class SettingsController extends GetxController {
  LanguageController get _languageController {
    if (Get.isRegistered<LanguageController>()) {
      return Get.find<LanguageController>();
    }
    return Get.put(LanguageController(), permanent: true);
  }

  Locale get currentLocale => _languageController.locale.value;
  String get currentLanguageLabel => _languageController.currentLanguageLabel;

  Future<void> setLanguage(Locale locale) async {
    await _languageController.setLanguage(locale);
    update();
  }
}
