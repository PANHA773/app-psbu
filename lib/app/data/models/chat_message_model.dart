import '../../config.dart';

class ChatMessageModel {
  final String id;
  final String? recipient;
  final ChatSender sender;
  final String content;
  final bool isEdited;
  final String? image;
  final String? video;
  final String? audio;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessageModel({
    required this.id,
    this.recipient,
    required this.sender,
    required this.content,
    required this.isEdited,
    this.image,
    this.video,
    this.audio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id']?.toString() ?? '',
      recipient: json['recipient']?.toString(),
      sender: ChatSender.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      isEdited: json['isEdited'] ?? false,
      image: _parseMediaUrl(json['image']),
      video: _parseMediaUrl(json['video']),
      audio: _parseMediaUrl(json['audio']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static String? _parseMediaUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    String url = value.toString();

    // Handle full URLs from backend that contain localhost
    if (url.startsWith('http://localhost:')) {
      final uri = Uri.parse(url);
      url = uri.path.substring(1); // Remove leading slash
    }

    // Replace localhost with dynamic host (e.g., 10.0.2.2 for Android)
    if (url.contains('localhost')) {
      url = url.replaceAll('localhost', AppConfig.host);
    }

    if (url.startsWith('http')) {
      return url;
    }

    return '${AppConfig.baseUrl}/$url';
  }
}

class ChatSender {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? bio;
  final String? gender;

  ChatSender({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.bio,
    this.gender,
  });

  factory ChatSender.fromJson(Map<String, dynamic> json) {
    return ChatSender(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: ChatMessageModel._parseMediaUrl(json['avatar']),
      bio: json['bio'],
      gender: json['gender'],
    );
  }
}
