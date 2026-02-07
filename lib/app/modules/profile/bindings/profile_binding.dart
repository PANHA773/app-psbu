import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// ProfileBinding handles dependency injection for Profile module
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // LazyPut ensures the controller is created only when first used,
    // and disposed automatically when not needed
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
