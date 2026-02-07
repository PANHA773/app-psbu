import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
