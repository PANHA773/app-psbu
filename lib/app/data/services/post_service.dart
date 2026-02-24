import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/news_model.dart';
import '../models/category_model.dart';
import 'dio_client.dart';

class PostService {
  // ===================== Helpers =====================
  static Map<String, dynamic> _extractMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      if (rawData.containsKey('data') && rawData['data'] is Map<String, dynamic>) {
        return rawData['data'];
      }
      return rawData;
    }
    if (rawData is Map) {
      // Looser map typing
      final map = Map<String, dynamic>.from(rawData);
      if (map.containsKey('data') && map['data'] is Map) {
        return Map<String, dynamic>.from(map['data']);
      }
      return map;
    }
    if (rawData is String) {
      throw Exception(rawData);
    }
    throw Exception('Invalid server response');
  }

  static List _extractList(dynamic rawData) {
    if (rawData is List) return rawData;
    if (rawData is Map && rawData.containsKey('data') && rawData['data'] is List) {
      return rawData['data'];
    }
    if (rawData is String) {
      throw Exception(rawData);
    }
    throw Exception('Invalid server response');
  }

  // ===================== Create =====================
  static Future<NewsModel> createPost({
    required String title,
    required String content,
    String? imagePath,
    String? videoPath,
    required String categoryId,
  }) async {
    try {
      final String safeTitle = title.trim();
      final String safeContent = content.trim();
      final bool hasImage = imagePath != null && imagePath.isNotEmpty;
      final bool hasVideo = videoPath != null && videoPath.isNotEmpty;

      dynamic payload;

      if (hasImage || hasVideo) {
        final formData = FormData();
        formData.fields.add(MapEntry('title', safeTitle));
        formData.fields.add(MapEntry('content', safeContent));
        formData.fields.add(MapEntry('category', categoryId));

        if (hasImage) {
          formData.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(
                imagePath!,
                filename: p.basename(imagePath),
              ),
            ),
          );
        }

        if (hasVideo) {
          formData.files.add(
            MapEntry(
              'video',
              await MultipartFile.fromFile(
                videoPath!,
                filename: p.basename(videoPath),
              ),
            ),
          );
        }

        payload = formData;
      } else {
        payload = {
          'title': safeTitle,
          'content': safeContent,
          'category': categoryId,
        };
      }

      final response = await DioClient.dio.post(
        '/news',
        data: payload,
      );

      final postData = _extractMap(response.data);
      return NewsModel.fromJson(postData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to create post'));
    }
  }

  // ===================== Read =====================
  static Future<List<NewsModel>> fetchAllPosts() async {
    try {
      final response = await DioClient.dio.get('/news');
      final data = _extractList(response.data);

      return data.map((json) => NewsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to fetch posts',
      );
    }
  }

  static Future<List<NewsModel>> fetchPostsByAuthor(String authorId) async {
    try {
      final response = await DioClient.dio.get(
        '/news',
        queryParameters: {'author': authorId},
      );
      final data = _extractList(response.data);

      return data.map((json) => NewsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to fetch posts by author',
      );
    }
  }

  static Future<NewsModel> fetchPost(String postId) async {
    try {
      final response = await DioClient.dio.get('/news/$postId');
      final postData = _extractMap(response.data);

      return NewsModel.fromJson(postData);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to fetch post',
      );
    }
  }

  static Future<List<NewsModel>> fetchPostsByCategory(String categoryId) async {
    try {
      final response = await DioClient.dio.get('/news/category/$categoryId');
      final data = _extractList(response.data);

      return data.map((json) => NewsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to fetch posts by category',
      );
    }
  }

  // ===================== Update =====================
  static Future<NewsModel> updatePost(
      String postId, {
        String? title,
        String? content,
        String? imageUrl,
        String? videoUrl,
        String? categoryId,
      }) async {
    try {
      final response = await DioClient.dio.put(
        '/news/$postId',
        data: {
          'title': title,
          'content': content,
          'image': imageUrl,
          'video': videoUrl,
          'category': categoryId,
        }..removeWhere((_, v) => v == null),
      );

      final postData = _extractMap(response.data);
      return NewsModel.fromJson(postData);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to update post'));
    }
  }

  // ===================== Delete =====================
  static Future<void> deletePost(String postId) async {
    try {
      await DioClient.dio.delete('/news/$postId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to delete post'));
    }
  }

  // ===================== Bookmarks =====================
  static Future<List<NewsModel>> fetchBookmarkedPosts() async {
    try {
      final response = await DioClient.dio.get('/bookmarks');

      if (response.data is! List) {
        throw Exception('Invalid bookmarks response: Expected a List');
      }

      final List<dynamic> bookmarkList = response.data;
      final List<NewsModel> newsList = [];

      for (var item in bookmarkList) {
        if (item is Map<String, dynamic>) {
          // Check if the bookmark item contains a nested 'news' object
          if (item.containsKey('news') && item['news'] is Map<String, dynamic>) {
            newsList.add(NewsModel.fromJson(item['news']));
          } else {
            // Assume the item itself is the news object
            newsList.add(NewsModel.fromJson(item));
          }
        } else {
          // Log or handle items that are not in the expected format
          print('Skipping invalid bookmark item: $item');
        }
      }
      return newsList;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch bookmarks'));
    } catch (e) {
      // Catch other parsing errors
      throw Exception('Failed to parse bookmarks: $e');
    }
  }

  static Future<void> toggleBookmark(String postId) async {
    try {
      await DioClient.dio.put('/users/bookmark/$postId');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to toggle bookmark'));
    }
  }

  // ===================== Related =====================
  static Future<List<NewsModel>> fetchRelatedPosts(
      String categoryId,
      String currentPostId,
      ) async {
    try {
      final allPosts = await fetchAllPosts();
      return allPosts
          .where((p) => p.category == categoryId && p.id != currentPostId)
          .take(5)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Related posts error: $e');
      }
      return [];
    }
  }

  // ===================== Categories =====================
  static Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await DioClient.dio.get('/categories');
      final data = _extractList(response.data);

      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch categories'));
    }
  }

  static Future getPostById(String newsId) async {}

  static String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is String) return data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return e.message ?? fallback;
  }
}
