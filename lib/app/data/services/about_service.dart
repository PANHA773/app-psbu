import 'package:dio/dio.dart';
import '../models/about_model.dart';
import 'dio_client.dart';

class AboutService {
  static Future<AboutModel> fetchAbout() async {
    try {
      final Response response = await DioClient.dio.get('/about');

      if (response.data == null) {
        throw Exception('About data is null');
      }

      // ✅ DIRECT PARSE (NO data WRAPPER)
      return AboutModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      throw Exception('Failed to fetch about: $e');
    }
  }
}
