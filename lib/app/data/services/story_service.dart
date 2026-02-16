import 'dart:io';
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
    required File imageFile,
    String caption = '',
  }) async {
    try {
      final String fileName = imageFile.path.split('/').last;
      final FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'caption': caption,
      });

      final response = await _dio.post('/stories', data: formData);

      // DioClient already unwraps 'data' if present
      final storyData = response.data;
      return StoryModel.fromJson(storyData);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? e.message ?? 'Failed to create story';
      print('❌ StoryService createStory Error: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      print('❌ StoryService createStory Error: $e');
      rethrow;
    }
  }
}
