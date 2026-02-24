import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import 'dio_client.dart';

class ChatService {
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _dio.patch('/chat/$messageId', data: {'content': newContent});
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(
        e.response?.data,
        fallback: e.message ?? 'Failed to edit message',
      );
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _dio.delete('/chat/$messageId');
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(
        e.response?.data,
        fallback: e.message ?? 'Failed to delete message',
      );
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  final Dio _dio = DioClient.dio;

  ChatService() {
    // Uses the central DioClient which includes AuthInterceptor
  }

  Future<List<ChatMessageModel>> getMessages() async {
    try {
      final response = await _dio.get('/chat');

      final List<dynamic> data = _extractList(response.data);
      return data.map((json) => _mapToMessage(json)).toList();
    } on DioException catch (e) {
      final errorMsg =
          _extractErrorMessage(e.response?.data, fallback: e.message) ??
          'Server error';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ChatSender>> getConversations() async {
    try {
      final response = await _dio.get('/chat/conversations');

      final List<dynamic> data = _extractList(
        response.data,
        preferredKeys: const ['conversations', 'data'],
      );
      return data.map((json) => _mapToSender(json)).toList();
    } on DioException catch (e) {
      final errorMsg =
          _extractErrorMessage(e.response?.data, fallback: e.message) ??
          'Server error';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ChatMessageModel>> getConversationMessages(String userId) async {
    try {
      final response = await _dio.get('/chat/conversation/$userId');

      final List<dynamic> data = _extractList(
        response.data,
        preferredKeys: const ['messages', 'data'],
      );
      return data.map((json) => _mapToMessage(json)).toList();
    } on DioException catch (e) {
      final errorMsg =
          _extractErrorMessage(e.response?.data, fallback: e.message) ??
          'Server error';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> sendMessage(String content, {String? recipientId}) async {
    try {
      await _dio.post(
        '/chat',
        data: {
          'content': content,
          if (recipientId != null) 'recipientId': recipientId,
        },
      );
    } on DioException catch (e) {
      final errorMsg =
          _extractErrorMessage(e.response?.data, fallback: e.message) ??
          'Failed to send message';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> sendVoiceMessage(
    String filePath, {
    String? recipientId,
    String content = '[Voice message]',
  }) async {
    try {
      final formData = FormData.fromMap({
        'content': content,
        if (recipientId != null) 'recipientId': recipientId,
        'audio': await MultipartFile.fromFile(
          filePath,
          filename: 'voice_message.m4a',
          contentType: DioMediaType.parse('audio/mp4'),
        ),
      });

      await _dio.post('/chat', data: formData);
    } on DioException catch (e) {
      final errorMsg =
          _extractErrorMessage(e.response?.data, fallback: e.message) ??
          'Failed to send voice message';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Safely extracts a list from a variety of common API shapes.
  List<dynamic> _extractList(
    dynamic raw, {
    List<String> preferredKeys = const ['data'],
  }) {
    if (raw is List) return raw;

    if (raw is Map) {
      // Check preferred keys first
      for (final key in preferredKeys) {
        final value = raw[key];
        if (value is List) return value;
        if (value is Map) {
          // Look for preferred keys one level deeper
          for (final nestedKey in preferredKeys) {
            final nestedValue = value[nestedKey];
            if (nestedValue is List) return nestedValue;
          }
          // Or any list inside that nested map
          for (final nestedValue in value.values) {
            if (nestedValue is List) return nestedValue;
          }
        }
      }

      // Generic fallbacks
      for (final value in raw.values) {
        if (value is List) return value;
        if (value is Map) {
          for (final nested in value.values) {
            if (nested is List) return nested;
          }
        }
      }
    }

    throw Exception('Unexpected response format from server');
  }

  ChatMessageModel _mapToMessage(dynamic json) {
    if (json is Map<String, dynamic>) return ChatMessageModel.fromJson(json);
    if (json is Map) {
      return ChatMessageModel.fromJson(Map<String, dynamic>.from(json));
    }
    throw Exception('Invalid message item type: ${json.runtimeType}');
  }

  ChatSender _mapToSender(dynamic json) {
    if (json is Map<String, dynamic>) return ChatSender.fromJson(json);
    if (json is Map) {
      return ChatSender.fromJson(Map<String, dynamic>.from(json));
    }
    throw Exception('Invalid conversation item type: ${json.runtimeType}');
  }

  String? _extractErrorMessage(dynamic data, {String? fallback}) {
    if (data == null) return fallback;
    if (data is String) return data;
    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;
      // common nested shape
      if (data['error'] is String) return data['error'] as String;
    }
    return fallback ?? 'Server error';
  }
}
