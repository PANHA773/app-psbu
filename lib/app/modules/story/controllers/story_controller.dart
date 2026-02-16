import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/story_model.dart';
import '../../../data/services/story_service.dart';

class StoryController extends GetxController {
  final StoryService _storyService = StoryService();
  final ImagePicker _picker = ImagePicker();

  final RxList<StoryModel> stories = <StoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStories();
  }

  Future<void> fetchStories() async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await _storyService.getStories();
      stories.assignAll(data);
    } catch (e) {
      error.value = 'Failed to load stories: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndPostStory() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      // Ask for caption (Optional but good UX)
      final caption = await _showCaptionDialog();

      isPosting.value = true;

      final newStory = await _storyService.createStory(
        imageFile: File(image.path),
        caption: caption ?? '',
      );

      // Add to local list and show success
      stories.insert(0, newStory);
      Get.snackbar(
        'Success',
        'Story posted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to post story: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isPosting.value = false;
    }
  }

  Future<String?> _showCaptionDialog() async {
    final TextEditingController captionController = TextEditingController();
    return await Get.dialog<String>(
      AlertDialog(
        title: const Text('Add Caption'),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Skip')),
          ElevatedButton(
            onPressed: () => Get.back(result: captionController.text),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
