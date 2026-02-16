import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/post_service.dart';
import '../../../data/services/auth_service.dart';

class PostController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final imageController = TextEditingController();
  final videoController = TextEditingController();

  final categories = <CategoryModel>[].obs;
  final selectedCategory = Rxn<CategoryModel>();

  final isLoading = false.obs;
  final isPublishing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    imageController.dispose();
    videoController.dispose();
    super.onClose();
  }

  // -------------------- Categories --------------------
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final data = await CategoryService.fetchCategories();

      categories.assignAll(data);
      if (data.isNotEmpty) {
        selectedCategory.value = data.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- Submit Post --------------------
  Future<void> submitPost() async {
    print('🚀 SUBMIT POST CALLED');

    // ---------- AUTH CHECK ----------
    try {
      final currentUser = await AuthService.getCurrentUser();

      if (currentUser == null) {
        Get.snackbar('Access denied', 'Please sign in to create a post.');
        return;
      }

      // Everyone who is logged in can now post
    } catch (e) {
      print('⚠️ Auth error: $e');
      Get.snackbar('Error', 'Failed to verify user');
      return;
    }

    // ---------- FORM VALIDATION ----------
    if (!formKey.currentState!.validate()) {
      print('❌ FORM VALIDATION FAILED');
      return;
    }

    if (selectedCategory.value == null) {
      Get.snackbar('Error', 'Please select a category.');
      return;
    }

    // ---------- SUBMIT ----------
    try {
      isPublishing.value = true;

      await PostService.createPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        imageUrl: imageController.text.trim(),
        videoUrl: videoController.text.trim(),
        categoryId: selectedCategory.value!.id,
      );

      Get.back();
      Get.snackbar('Success', 'Post submitted successfully!');
    } catch (e) {
      print('❌ Create post failed: $e');

      String message = e.toString();
      if (message.startsWith('Exception:')) {
        message = message.replaceFirst('Exception:', '').trim();
      }

      Get.snackbar('Error', message);
    } finally {
      isPublishing.value = false;
    }
  }
}
