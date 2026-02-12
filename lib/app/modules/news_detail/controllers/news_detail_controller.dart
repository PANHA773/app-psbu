import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../goods/controllers/goods_controller.dart';
import '../../../data/models/news_model.dart';
import '../../../data/services/post_service.dart';

class NewsCommentModel {
  final String id;
  final String? authorName;
  final String content;
  final String? createdAtFormatted;
  NewsCommentModel({required this.id, this.authorName, required this.content, this.createdAtFormatted});
}

class NewsDetailController extends GetxController {
  /// Current news
  final news = Rxn<NewsModel>();

  /// UI states
  final isLiked = false.obs;
  final isGood = false.obs;
  final likeCount = 0.obs;

  final relatedNews = <NewsModel>[].obs;
  final isLoadingRelated = false.obs;

  // Comments
  final comments = <NewsCommentModel>[].obs;
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is NewsModel) {
      _setNews(arg);
      fetchRelatedPosts();
      fetchComments();
    }
  }

  // ===================== Helpers =====================
  void _setNews(NewsModel data) {
    news.value = data;
    isGood.value = data.isBookmarked ?? false;
    likeCount.value = data.likes ?? 0;
  }

  // ===================== Fetch =====================
  Future<void> fetchNewsById(String newsId) async {
    try {
      final data = await PostService.getPostById(newsId);
      _setNews(data);
      fetchRelatedPosts();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to load news details.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchRelatedPosts() async {
    final currentNews = news.value;
    if (currentNews == null) return;

    try {
      isLoadingRelated.value = true;

      final categoryId = currentNews.category is String
          ? currentNews.category
          : currentNews.category?.id;

      if (categoryId == null) return;

      final data = await PostService.fetchRelatedPosts(
        categoryId,
        currentNews.id,
      );

      relatedNews.assignAll(data);
    } catch (e) {
      debugPrint('⚠️ Related posts error: $e');
    } finally {
      isLoadingRelated.value = false;
    }
  }

  // ===================== Comments =====================
  void fetchComments() {
    // TODO: Replace with backend call
    comments.assignAll([
      NewsCommentModel(id: '1', authorName: 'Alice', content: 'Great article!', createdAtFormatted: '12/2/2026'),
      NewsCommentModel(id: '2', authorName: 'Bob', content: 'Thanks for sharing.', createdAtFormatted: '12/2/2026'),
    ]);
  }

  void addComment() {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    comments.add(NewsCommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'Me',
      content: text,
      createdAtFormatted: 'Now',
    ));
    commentController.clear();
  }

  // ===================== Actions =====================
  void updateNews(NewsModel updatedNews) {
    _setNews(updatedNews);
  }

  void toggleLike() {
    isLiked.toggle();
    likeCount.value += isLiked.value ? 1 : -1;
    if (likeCount.value < 0) likeCount.value = 0;
  }

  Future<void> toggleGood() async {
    final current = news.value;
    if (current == null) return;

    try {
      await PostService.toggleBookmark(current.id);
      isGood.toggle();

      if (Get.isRegistered<GoodsController>()) {
        Get.find<GoodsController>().fetchGoods();
      }

      Get.snackbar(
        isGood.value ? 'Saved' : 'Removed',
        isGood.value
            ? 'Article saved successfully.'
            : 'Article removed successfully.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception:', '').trim(),
      );
    }
  }

  void shareNews() {
    Get.snackbar(
      'Share',
      'Sharing feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ===================== Open Document =====================
  Future<void> openDocument(String url) async {
    try {
      final uri = Uri.parse(url);

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not open document';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open document.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
    }
  }
}
