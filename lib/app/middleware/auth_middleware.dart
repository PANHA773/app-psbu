import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AuthService.token == null) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }

  // Alternative: use onPageBuilt or similar, but redirect is better for blocking.
}
