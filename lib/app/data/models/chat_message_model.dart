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
      createdAt: AppConfig.parseDateTimeLocal(json['createdAt']),
      updatedAt: AppConfig.parseDateTimeLocal(json['updatedAt']),
    );
  }

  static String? _parseMediaUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return AppConfig.transformUrl(value.toString());
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
      name: json['name'] ?? json['fullName'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: _parseAvatarUrl(json['avatar']),
      bio: json['bio'],
      gender: json['gender'],
    );
  }

  static String? _parseAvatarUrl(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return null;

    // Legacy upload paths often point to deleted files and spam 404s.
    if (raw.startsWith('/uploads/') || raw.contains('/uploads/')) return null;

    return ChatMessageModel._parseMediaUrl(raw);
  }
}
