import 'package:flutter/foundation.dart';

class AppConfig {
  static const String host = 'news-project-wnkb.onrender.com';
  static const String baseUrl = 'https://$host';
  static const String apiVersion = '/api';
  static String get apiUrl => '$baseUrl$apiVersion';
  static String get imageUrl => baseUrl;

  /// Agora.io App ID for voice/video calls.
  /// Get yours at https://console.agora.io/
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';

  /// Helper to fix localhost image URLs on Emulator/Device
  static String transformUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String transformed = url;

    // If it's a relative path, prepend baseUrl.
    if (!transformed.startsWith('http')) {
      transformed =
          '$baseUrl/${transformed.startsWith('/') ? transformed.substring(1) : transformed}';
    }

    // Replace local URLs with deployed host.
    final needsTransformation =
        transformed.contains('localhost') || transformed.contains('127.0.0.1');

    if (needsTransformation) {
      final old = transformed;
      transformed = transformed
          .replaceAll('localhost', host)
          .replaceAll('127.0.0.1', host);
      debugPrint('AppConfig: Fixed $old -> $transformed');
    }

    return transformed;
  }
}
