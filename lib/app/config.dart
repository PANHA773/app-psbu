import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get host {
    if (kIsWeb) return 'localhost';
    String result = '127.0.0.1';
    try {
      if (Platform.isAndroid)
        result = '10.0.2.2';
      else if (Platform.isIOS)
        result = '127.0.0.1';
    } catch (_) {}

    // Check if we should log (only once or when it changes)
    if (kDebugMode) {
      // print('🌐 AppConfig: Detected host IP: $result');
    }
    return result;
  }

  static String get baseUrl => 'http://$host:5000';
  static const String apiVersion = '/api';
  static String get apiUrl => '$baseUrl$apiVersion';
  static String get imageUrl => baseUrl; // Base URL for images

  /// Helper to fix localhost image URLs on Emulator/Device
  static String transformUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String transformed = url;

    // If it's a relative path, prepend baseUrl
    if (!transformed.startsWith('http')) {
      transformed =
          '$baseUrl/${transformed.startsWith('/') ? transformed.substring(1) : transformed}';
    }

    // Always replace localhost/127.0.0.1 with the correct host for the current platform
    // but ONLY if the current host is DIFFERENT from the one in the URL.
    final needsTransformation =
        transformed.contains('localhost') ||
        (transformed.contains('127.0.0.1') && host != '127.0.0.1');

    if (needsTransformation) {
      final old = transformed;
      transformed = transformed
          .replaceAll('localhost', host)
          .replaceAll('127.0.0.1', host);
      debugPrint('🔄 AppConfig: Fixed $old → $transformed');
    }

    // Print for debugging if it still contains localhost in an environment it shouldn't
    return transformed;
  }
}
