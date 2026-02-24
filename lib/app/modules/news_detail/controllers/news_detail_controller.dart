import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:university_news_app/app/config.dart';

import '../../goods/controllers/goods_controller.dart';
import '../../../data/models/news_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/services/post_service.dart';
import '../../../data/services/comment_service.dart';
import '../../../data/services/dio_client.dart';
import '../../../data/services/auth_service.dart';

class NewsDetailController extends GetxController {
  /// Current news
  final news = Rxn<NewsModel>();

  /// UI states
  final RxBool isLiked = false.obs;
  final RxBool isGood = false.obs;
  final RxInt likeCount = 0.obs;

  final relatedNews = <NewsModel>[].obs;
  final isLoadingRelated = false.obs;
  final isLoadingComments = false.obs;
  final RxString currentUserId = ''.obs;

  // Comments
  final comments = <CommentModel>[].obs;
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    _loadCurrentUser();

    final arg = Get.arguments;
    if (arg is NewsModel) {
      _setNews(arg);
      fetchRelatedPosts();
      fetchComments();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null && user['_id'] != null) {
        currentUserId.value = user['_id'].toString();
      }
    } catch (_) {
      // ignore; user not logged in or fetch failed
    }
  }

  // ===================== Helpers =====================
  void _setNews(NewsModel data) {
    news.value = data;
    isGood.value = data.isBookmarked;
    isLiked.value = data.isLiked;
    likeCount.value = data.likes;
  }

  // ===================== Fetch =====================
  Future<void> fetchNewsById(String newsId) async {
    try {
      final data = await PostService.getPostById(newsId);
      _setNews(data);
      fetchRelatedPosts();
      fetchComments();
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

      final categoryId = currentNews.category;

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
  Future<void> fetchComments() async {
    final currentNews = news.value;
    if (currentNews == null) return;

    try {
      isLoadingComments.value = true;
      final data = await CommentService.fetchComments(currentNews.id);
      comments.assignAll(data);
    } catch (e) {
      debugPrint('⚠️ Fetch comments error: $e');
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> addComment() async {
    final currentNews = news.value;
    if (currentNews == null) return;

    final text = commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final newComment = await CommentService.createComment(
        currentNews.id,
        text,
      );

      // 👤 If the server returns "Unknown" (e.g. not populated), fix it locally
      var finalComment = newComment;
      if (newComment.authorName == 'Unknown') {
        final user = await AuthService.getCurrentUser();
        if (user != null) {
          finalComment = CommentModel(
            id: newComment.id,
            content: newComment.content,
            authorName: user['name'] ?? user['fullName'] ?? 'Me',
            authorId: user['_id']?.toString(),
            authorAvatar: AppConfig.transformUrl(
              newComment.authorAvatar ?? user['avatar'],
            ),
            createdAt: newComment.createdAt ?? DateTime.now(),
          );
        }
      }

      comments.insert(0, finalComment); // Add to top of the list
      commentController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> editComment({
    required String commentId,
    required String content,
  }) async {
    final currentNews = news.value;
    if (currentNews == null || content.trim().isEmpty) return;

    try {
      final updated = await CommentService.editComment(
        currentNews.id,
        commentId,
        content.trim(),
      );

      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index] = updated;
        comments.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    final currentNews = news.value;
    if (currentNews == null) return;

    try {
      await CommentService.deleteComment(currentNews.id, commentId);
      comments.removeWhere((c) => c.id == commentId);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // ===================== Actions =====================
  void updateNews(NewsModel updatedNews) {
    _setNews(updatedNews);
  }

  Future<void> toggleLike() async {
    final currentNews = news.value;
    if (currentNews == null) return;

    try {
      // Optimistic update
      isLiked.toggle();
      likeCount.value += isLiked.value ? 1 : -1;
      if (likeCount.value < 0) likeCount.value = 0;

      await DioClient.dio.post('/news/${currentNews.id}/like');
    } catch (e) {
      // Revert on error
      isLiked.toggle();
      likeCount.value += isLiked.value ? 1 : -1;
      if (likeCount.value < 0) likeCount.value = 0;

      Get.snackbar(
        'Error',
        'Failed to update like status.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
      Get.snackbar('Error', e.toString().replaceFirst('Exception:', '').trim());
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
