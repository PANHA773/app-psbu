import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/services/post_service.dart'; // Changed from NewsService

class HomeController extends GetxController {
  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  var newsList = <NewsModel>[].obs;
  var currentSliderIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllPosts(); // Renamed from fetchNews
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  /// Fetch all posts from API
  Future<void> fetchAllPosts() async {
    try {
      isLoading(true);
      final data = await PostService.fetchAllPosts(); // Using PostService

      if (data.isNotEmpty) {
        newsList.assignAll(data);
      } else {
        // API returned an empty list — clear any existing items and
        // let the UI display the friendly empty-state message instead
        // of showing an error snackbar.
        newsList.clear();
        currentSliderIndex.value = 0;
      }
    } catch (e) {
      _showError(
        'Failed to load posts. Please check your internet connection.',
        error: e,
      );
    } finally {
      isLoading(false);
    }
  }

  /// Change slider index
  void changeSliderIndex(int index) {
    currentSliderIndex.value = index;
  }

  /// Get featured news for slider
  List<NewsModel> get featuredNews {
    return newsList.take(5).toList();
  }

  /// Get news by category
  List<NewsModel> getNewsByCategory(String category) {
    return newsList.where((news) => news.categoryName == category).toList();
  }

  /// Refresh news with pull-to-refresh
  Future<void> refreshPosts() async {
    await fetchAllPosts();
  }

  /// Search news
  List<NewsModel> searchNews(String query) {
    if (query.isEmpty) return newsList;

    return newsList.where((news) {
      return news.title.toLowerCase().contains(query.toLowerCase()) ||
          news.content.toLowerCase().contains(query.toLowerCase()) ||
          news.authorName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Friendly error snackbar
  void _showError(String message, {dynamic error}) {
    if (kDebugMode && error != null) {
      print('DEBUG ERROR: $error');
    }

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: fetchAllPosts, // Retry button
        child: const Text('Retry', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void navigateToNewsDetail(NewsModel news) {
    Get.toNamed('/news-detail', arguments: news);
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 🌤️';
    return 'Good Evening! 🌙';
  }
}