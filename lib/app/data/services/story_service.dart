import 'dart:io';
import 'package:dio/dio.dart';
import '../models/story_model.dart';
import 'dio_client.dart';

class StoryService {
  final Dio _dio = DioClient.dio;

  Future<List<StoryModel>> getStories() async {
    try {
      final response = await _dio.get('/stories');
      final dynamic raw = response.data;

      if (raw is List) {
        return raw.map((json) => StoryModel.fromJson(json)).toList();
      }

      if (raw is Map && raw['stories'] is List) {
        final List<dynamic> data = raw['stories'] as List<dynamic>;
        return data.map((json) => StoryModel.fromJson(json)).toList();
      }

      return <StoryModel>[];
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      String message = 'Failed to load stories';

      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }

      if (status == 401) {
        throw Exception('Please login again to load stories');
      }

      if (status != null && status >= 500) {
        // Backend-side failure. Keep app usable by showing empty stories.
        return <StoryModel>[];
      }

      throw Exception(message);
    } catch (_) {
      throw Exception('Failed to load stories');
    }
  }

  Future<StoryModel> createStory({
    required File mediaFile,
    bool isVideo = false,
    String caption = '',
  }) async {
    try {
      final String fileName = mediaFile.path.split('/').last;
      final String fieldName = isVideo ? 'video' : 'image';
      final FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          mediaFile.path,
          filename: fileName,
        ),
        'caption': caption,
        'mediaType': isVideo ? 'video' : 'image',
      });

      final response = await _dio.post('/stories', data: formData);

      // DioClient already unwraps 'data' if present.
      final storyData = response.data;
      return StoryModel.fromJson(storyData);
    } on DioException catch (e) {
      final dynamic data = e.response?.data;
      String errorMsg = e.message ?? 'Failed to create story';

      if (data is Map && data['message'] != null) {
        errorMsg = data['message'].toString();
      }

      throw Exception(errorMsg);
    } catch (_) {
      throw Exception('Failed to create story');
    }
  }

  /// Try to increment the view count for a story.
  /// Probes a few possible endpoints to support different backends.
  Future<bool> incrementStoryView(String storyId) async {
    final endpoints = [
      '/stories/$storyId/view',
      '/story/$storyId/view',
      '/stories/$storyId/views',
      '/story/$storyId/views',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.post(
          endpoint,
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode == 404) {
          continue;
        }

        // Consider success for any 2xx/3xx response
        if (response.statusCode != null && response.statusCode! < 400) {
          return true;
        }
      } on DioException catch (_) {
        // Try next endpoint
        continue;
      } catch (_) {
        continue;
      }
    }

    // All candidate endpoints failed.
    return false;
  }
}
