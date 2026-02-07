import 'package:get/get.dart';

import '../controllers/new_message_controller.dart';

class NewMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewMessageController>(
      () => NewMessageController(),
    );
  }
}
