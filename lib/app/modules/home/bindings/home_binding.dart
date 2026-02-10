import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../goods/controllers/goods_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../post/controllers/post_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../my-posts/controllers/my_posts_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<GoodsController>(() => GoodsController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<PostController>(() => PostController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MyPostsController>(() => MyPostsController());
  }
}
