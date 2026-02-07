import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/news_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/post_service.dart'; // Import PostService

class CategoryController extends GetxController {
  var isLoadingCategories = false.obs;
  var isLoadingPosts = false.obs;
  var categoryList = <CategoryModel>[].obs;
  var postList = <NewsModel>[].obs; // To store posts of a selected category
  var selectedCategory = Rxn<CategoryModel>();



  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories(true);
      final data = await CategoryService.fetchCategories();
      categoryList.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories.');
    } finally {
      isLoadingCategories(false);
    }
  }

  Future<void> fetchPostsForCategory(String categoryId) async {
    try {
      isLoadingPosts(true);
      final data = await PostService.fetchPostsByCategory(categoryId);
      postList.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load posts for this category.');
    } finally {
      isLoadingPosts(false);
    }
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
    fetchPostsForCategory(category.id); // Fetch posts when a category is selected
  }
}
