import 'package:get/get.dart';
import '../../../data/models/story_model.dart';
import '../../../data/services/story_service.dart';

class StoryController extends GetxController {
  final StoryService _storyService = StoryService();

  final RxList<StoryModel> stories = <StoryModel>[].obs;
  final RxBool isLoading = false.obs;
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
}
