import '../../config.dart';

class StoryUser {
  final String id;
  final String name;
  final String? avatar;

  StoryUser({required this.id, required this.name, this.avatar});

  factory StoryUser.fromJson(Map<String, dynamic> json) {
    return StoryUser(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
      avatar: _parseAvatarUrl(json['avatar']),
    );
  }

  static String? _parseAvatarUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return AppConfig.transformUrl(value.toString());
  }
}

class StoryModel {
  final String id;
  final StoryUser user;
  final String image;
  final String caption;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.user,
    required this.image,
    required this.caption,
    this.expiresAt,
    this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id']?.toString() ?? '',
      user: StoryUser.fromJson(json['user'] ?? {}),
      image: _parseImageUrl(json['image']),
      caption: json['caption'] ?? '',
      expiresAt: _parseDate(json['expiresAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static String _parseImageUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return '';
    return AppConfig.transformUrl(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
