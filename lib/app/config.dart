import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return 'localhost';
  }

  static String get baseUrl => 'http://$host:5000';
  static const String apiVersion = '/api';
  static String get apiUrl => '$baseUrl$apiVersion';
  static String get imageUrl => baseUrl; // Base URL for images

  /// Helper to fix localhost image URLs on Android Emulator
  static String transformUrl(String url) {
    if (Platform.isAndroid && url.contains('localhost')) {
      return url.replaceFirst('localhost', '10.0.2.2');
    }
    return url;
  }
}
