import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import 'dio_client.dart';

class CommentService {
  static Future<List<CommentModel>> fetchComments(String newsId) async {
    try {
      final Response response = await DioClient.dio.get(
        '/news/$newsId/comments',
      );

      final List rawData =
          response.data is Map && response.data.containsKey('data')
          ? response.data['data']
          : response.data;

      if (rawData is! List) {
        throw Exception('Invalid data format from server');
      }

      return rawData.map((json) => CommentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? e.message ?? 'Server error';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<CommentModel> createComment(
    String newsId,
    String content,
  ) async {
    try {
      final Response response = await DioClient.dio.post(
        '/news/$newsId/comments',
        data: {'content': content},
      );

      final Map<String, dynamic> rawData =
          response.data is Map && response.data.containsKey('data')
          ? response.data['data']
          : response.data;

      return CommentModel.fromJson(rawData);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? e.message ?? 'Server error';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<CommentModel> editComment(
    String newsId,
    String commentId,
    String content,
  ) async {
    try {
      final Response response = await DioClient.dio.patch(
        '/news/$newsId/comments/$commentId',
        data: {'content': content},
      );

      final Map<String, dynamic> rawData =
          response.data is Map && response.data.containsKey('data')
          ? response.data['data']
          : response.data;

      return CommentModel.fromJson(rawData);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? e.message ?? 'Failed to edit comment';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<void> deleteComment(
    String newsId,
    String commentId,
  ) async {
    try {
      await DioClient.dio.delete('/news/$newsId/comments/$commentId');
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          e.message ??
          'Failed to delete comment';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
