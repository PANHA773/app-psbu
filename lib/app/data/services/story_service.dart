import 'package:dio/dio.dart';
import '../models/story_model.dart';
import 'dio_client.dart';

class StoryService {
  final Dio _dio = DioClient.dio;

  Future<List<StoryModel>> getStories() async {
    try {
      final response = await _dio.get('/stories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StoryModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load stories');
    } catch (e) {
      print('❌ StoryService getStories Error: $e');
      rethrow;
    }
  }

  Future<StoryModel> createStory({
    required String image,
    String caption = '',
  }) async {
    try {
      final response = await _dio.post(
        '/stories',
        data: {
          'image': image,
          'caption': caption,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StoryModel.fromJson(response.data);
      }
      throw Exception('Failed to create story');
    } catch (e) {
      print('❌ StoryService createStory Error: $e');
      rethrow;
    }
  }
}
