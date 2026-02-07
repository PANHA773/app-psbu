import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import 'dio_client.dart';

class ChatService {
  final Dio _dio = DioClient.dio;

  ChatService() {
    // Uses the central DioClient which includes AuthInterceptor
  }

  Future<List<ChatMessageModel>> getMessages() async {
    try {
      final response = await _dio.get('/chat');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatMessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('❌ ChatService Error: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String content, {String? recipientId}) async {
    try {
      await _dio.post(
        '/chat',
        data: {
          'content': content,
          if (recipientId != null) 'recipient': recipientId,
        },
      );
    } catch (e) {
      print('❌ ChatService Send Error: $e');
      rethrow;
    }
  }
}
