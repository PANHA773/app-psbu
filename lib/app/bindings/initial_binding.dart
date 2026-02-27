import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../data/services/chat_alert_service.dart';
import '../data/services/webrtc_service.dart';
import '../controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize your core controllers here
    Get.put(AuthController(), permanent: true);
    Get.put(ChatAlertService(), permanent: true).init();
    Get.put(WebRTCService(), permanent: true);
    Get.put(ThemeController(), permanent: true);
  }
}
