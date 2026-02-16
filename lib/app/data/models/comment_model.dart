import '../../config.dart';

class CommentModel {
  final String id;
  final String content;
  final String authorName;
  final String? authorId;
  final String? authorAvatar;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.authorName,
    this.authorId,
    this.authorAvatar,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String name = 'Unknown';
    String? authorId;
    String? avatar;

    final authorData = json['author'] ?? json['user'];

    if (authorData is Map) {
      final author = authorData as Map<String, dynamic>;
      authorId = author['_id']?.toString();
      name =
          author['name'] ??
          author['fullName'] ??
          author['username'] ??
          'Unknown';
      avatar = author['avatar'];
    } else if (json['authorName'] != null) {
      // Fallback for some API patterns
      name = json['authorName'];
      avatar = json['authorAvatar'];
      authorId = json['authorId']?.toString();
    }

    return CommentModel(
      id: json['_id']?.toString() ?? '',
      content: json['content'] ?? '',
      authorName: name,
      authorId: authorId,
      authorAvatar: _parseMediaUrl(avatar),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  static String? _parseMediaUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    final original = value.toString();
    final transformed = AppConfig.transformUrl(original);
    // debugPrint('👤 CommentModel: Avatar $original → $transformed');
    return transformed;
  }

  String get createdAtFormatted {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }
}
