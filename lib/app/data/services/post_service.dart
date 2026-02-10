import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    throw Exception('Invalid server response');
  }

  static List _extractList(dynamic rawData) {
    if (rawData is List) return rawData;
    if (rawData is Map && rawData.containsKey('data') && rawData['data'] is List) {
      return rawData['data'];
    }
    throw Exception('Invalid server response');
  }

  // ===================== Create =====================
  static Future<NewsModel> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String? videoUrl,
    required String categoryId,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/news',
        data: {
          'title': title,
          'content': content,
          'image': imageUrl?.isNotEmpty == true ? imageUrl : null,
          'video': videoUrl?.isNotEmpty == true ? videoUrl : null,
          'category': categoryId,
        },
      );

      final postData = _extractMap(response.data);
      return NewsModel.fromJson(postData);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to create post',
      );
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
      final response = await DioClient.dio.patch(
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
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to update post',
      );
    }
  }

  // ===================== Delete =====================
  static Future<void> deletePost(String postId) async {
    try {
      await DioClient.dio.delete('/news/$postId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to delete post',
      );
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
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to fetch bookmarks',
      );
    } catch (e) {
      // Catch other parsing errors
      throw Exception('Failed to parse bookmarks: $e');
    }
  }

  static Future<void> toggleBookmark(String postId) async {
    try {
      await DioClient.dio.put('/users/bookmark/$postId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to toggle bookmark',
      );
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
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to fetch categories',
      );
    }
  }

  static Future getPostById(String newsId) async {}
}
