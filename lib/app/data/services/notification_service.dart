import 'package:dio/dio.dart';
import 'dio_client.dart';

class NotificationService {
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await DioClient.dio.get('/notifications');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await DioClient.dio.patch('/notifications/$notificationId', data: {'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}

class NotificationModel {
  final String id;
  final String recipient;
  final Sender sender;
  final String type;
  final String link;
  final bool isRead;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    required this.sender,
    required this.type,
    required this.link,
    required this.isRead,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      recipient: json['recipient'],
      sender: Sender.fromJson(json['sender']),
      type: json['type'],
      link: json['link'],
      isRead: json['isRead'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Sender {
  final String id;
  final String name;
  final String avatar;

  Sender({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }
}
