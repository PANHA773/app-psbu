import 'package:dio/dio.dart';
import '../models/news_model.dart';
import 'dio_client.dart';

class NewsService {
  static Future<List<NewsModel>> fetchNews() async {
    try {
      final Response response = await DioClient.dio.get('/news');

      final dynamic rawData = response.data;

      if (rawData is! List) {
        throw Exception('Invalid data format from server');
      }

      return rawData.map((json) => NewsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = e.message ?? 'Server error';
      if (data is Map && data.containsKey('message')) {
        errorMsg = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        errorMsg = data;
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<Response> createPost(Map<String, dynamic> postData) async {
    try {
      return await DioClient.dio.post('/news', data: postData);
    } catch (e) {
      rethrow;
    }
  }



  static Future<void> toggleBookmark(String newsId) async {
    try {
      print('🚀 NewsService: Toggling bookmark for $newsId...');
      await DioClient.dio.put('/users/bookmark/$newsId');
      print('✅ NewsService: Toggle successful');
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = e.message ?? 'Server error';
      if (data is Map && data.containsKey('message')) {
        errorMsg = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        errorMsg = data;
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<List<NewsModel>> fetchRelatedNews(
    String categoryName,
    String currentNewsId,
  ) async {
    try {
      final List<NewsModel> allNews = await fetchNews();
      return allNews
          .where((n) => n.categoryName == categoryName && n.id != currentNewsId)
          .take(5)
          .toList();
    } catch (e) {
      print('⚠️ Failed to fetch related news: $e');
      return [];
    }
  }

  static Future getNewsById(String newsId) async {}
}
