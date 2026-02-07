import 'package:get/get.dart';
import '../controllers/goods_controller.dart';

class GoodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoodsController>(() => GoodsController());
  }
}
