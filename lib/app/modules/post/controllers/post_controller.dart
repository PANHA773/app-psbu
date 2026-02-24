import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/post_service.dart';
import '../../../data/services/auth_service.dart';

class PostController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final RxString imagePath = ''.obs;
  final RxString videoPath = ''.obs;

  final categories = <CategoryModel>[].obs;
  final selectedCategory = Rxn<CategoryModel>();

  final isLoading = false.obs;
  final isPublishing = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // -------------------- Media Pickers --------------------
  Future<void> pickImage() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file != null) {
      imagePath.value = file.path;
    }
  }

  Future<void> pickVideo() async {
    final XFile? file =
        await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
    if (file != null) {
      videoPath.value = file.path;
    }
  }

  void clearMedia() {
    imagePath.value = '';
    videoPath.value = '';
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

    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final hasMedia = imagePath.value.isNotEmpty || videoPath.value.isNotEmpty;

    // Allow publishing when either there is text (title/content) or media attached.
    if (title.isEmpty && content.isEmpty && !hasMedia) {
      Get.snackbar('Error', 'Please add a title or content, or attach media.');
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
        title: title,
        content: content,
        imagePath: imagePath.value.isNotEmpty ? imagePath.value : null,
        videoPath: videoPath.value.isNotEmpty ? videoPath.value : null,
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
