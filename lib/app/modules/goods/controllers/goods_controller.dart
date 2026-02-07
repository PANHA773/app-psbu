import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/services/post_service.dart';

class GoodsController extends GetxController {
  var goodsList = <NewsModel>[].obs;
  var isLoading = true.obs;
  var selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGoods();
  }

  /// Fetches bookmarked posts from the service.
  Future<void> fetchGoods() async {
    try {
      isLoading(true);
      final data = await PostService.fetchBookmarkedPosts();
      goodsList.assignAll(data);
    } catch (e) {
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      Get.snackbar(
        'Error Loading Goods',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () => fetchGoods(), // Retry button
          child: const Text(
            'Retry',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } finally {
      isLoading(false);
    }
  }

  /// Provides a filtered list of goods based on the selected category.
  List<NewsModel> get filteredGoods {
    if (selectedCategory.value == 'All') {
      return goodsList;
    }
    return goodsList
        .where((g) =>
            g.categoryName.toLowerCase() == selectedCategory.value.toLowerCase())
        .toList();
  }

  /// The total number of bookmarked items.
  int get totalItems => goodsList.length;

  /// The number of unique categories among the bookmarked items.
  int get categoryCount {
    return goodsList.map((g) => g.categoryName).toSet().length;
  }

  /// Changes the currently selected category filter.
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  /// Removes a post from bookmarks with optimistic UI update and error recovery.
  Future<void> removeGood(NewsModel news) async {
    final int index = goodsList.indexWhere((g) => g.id == news.id);
    if (index == -1) return; // Item not found

    // Optimistically remove the item from the list
    final removedItem = goodsList.removeAt(index);

    try {
      await PostService.toggleBookmark(news.id);
      Get.snackbar(
        'Removed',
        '"${news.title}" was removed from your goods.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // If the API call fails, add the item back to its original position
      goodsList.insert(index, removedItem);

      String errorMessage = e.toString().replaceAll("Exception: ", "");
      Get.snackbar(
        'Error',
        'Failed to remove: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// Public method to allow manual refresh from the UI (e.g., pull-to-refresh).
  Future<void> refreshGoods() async {
    await fetchGoods();
  }
}
