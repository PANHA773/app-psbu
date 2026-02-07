import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize your core controllers here
    Get.put(AuthController(), permanent: true);
  }
}
