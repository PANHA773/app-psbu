import '../../config.dart';

class CommentModel {
  final String id;
  final String content;
  final String authorName;
  final String? authorAvatar;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.authorName,
    this.authorAvatar,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id']?.toString() ?? '',
      content: json['content'] ?? '',
      authorName: json['author']?['name'] ?? 'Unknown',
      authorAvatar: _parseMediaUrl(json['author']?['avatar']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  static String? _parseMediaUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    String url = value.toString();
    if (url.contains('localhost')) {
      url = url.replaceAll('localhost', AppConfig.host);
    }
    if (url.startsWith('http')) {
      return url;
    }
    return '${AppConfig.baseUrl}/$url';
  }

  String get createdAtFormatted {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
}
