import '../../config.dart';

class FriendUser {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;

  FriendUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
  });

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: _parseAvatarUrl(json['avatar']),
      bio: json['bio'],
    );
  }

  static String? _parseAvatarUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    String url = value.toString();
    if (url.startsWith('http')) {
      return AppConfig.transformUrl(url);
    }
    return '${AppConfig.imageUrl}/$url';
  }
}
