import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import 'dio_client.dart';

class CommentService {
  static Future<List<CommentModel>> fetchComments(String newsId) async {
    try {
      final Response response = await DioClient.dio.get('/comments/news/$newsId');

      final List rawData = response.data is Map && response.data.containsKey('data')
          ? response.data['data']
          : response.data;

      if (rawData is! List) {
        throw Exception('Invalid data format from server');
      }

      return rawData.map((json) => CommentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Server error';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
