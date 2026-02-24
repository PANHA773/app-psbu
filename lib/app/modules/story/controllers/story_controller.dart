import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/story_model.dart';
import '../../../data/services/story_service.dart';

enum StoryMediaType { image, video }

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
      final StoryMediaType? mediaType = await _showMediaTypePicker();
      if (mediaType == null) return;

      XFile? media;
      if (mediaType == StoryMediaType.video) {
        media = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 2),
        );
      } else {
        media = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
      }

      if (media == null) return;

      // Ask for caption (Optional but good UX)
      final caption = await _showCaptionDialog();

      isPosting.value = true;

      final newStory = await _storyService.createStory(
        mediaFile: File(media.path),
        isVideo: mediaType == StoryMediaType.video,
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
      String msg = 'Failed to post story';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? e.message ?? msg;
      } else {
        msg = e.toString();
      }
      error.value = msg;
      Get.snackbar(
        'Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isPosting.value = false;
    }
  }

  Future<StoryMediaType?> _showMediaTypePicker() async {
    return await Get.bottomSheet<StoryMediaType>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Photo story'),
                onTap: () => Get.back(result: StoryMediaType.image),
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Video story'),
                onTap: () => Get.back(result: StoryMediaType.video),
              ),
            ],
          ),
        ),
      ),
      isDismissible: true,
    );
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
