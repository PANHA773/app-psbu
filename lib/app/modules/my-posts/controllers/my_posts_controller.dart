import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/post_service.dart';

class MyPostsController extends GetxController {
  final myPosts = <NewsModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyPosts();
  }

  Future<void> fetchMyPosts() async {
    try {
      isLoading.value = true;
      error.value = '';

      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null || currentUser['_id'] == null) {
        error.value = 'Please sign in to view your posts.';
        myPosts.clear();
        return;
      }

      final authorId = currentUser['_id'].toString();
      final data = await PostService.fetchPostsByAuthor(authorId);
      myPosts.assignAll(data);
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePost(NewsModel post) async {
    final index = myPosts.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    final removed = myPosts.removeAt(index);
    try {
      await PostService.deletePost(post.id);
      Get.snackbar('Deleted', '"${post.title}" removed.');
    } catch (e) {
      myPosts.insert(index, removed);
      Get.snackbar('Error', 'Failed to delete: ${_cleanError(e)}');
    }
  }

  Future<void> updatePost({
    required NewsModel post,
    required String title,
    required String content,
  }) async {
    try {
      final updated = await PostService.updatePost(
        post.id,
        title: title,
        content: content,
      );

      final index = myPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        myPosts[index] = updated;
      }
      Get.snackbar('Updated', 'Post updated successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: ${_cleanError(e)}');
    }
  }

  String _cleanError(Object e) => e.toString().replaceAll('Exception: ', '');
}
