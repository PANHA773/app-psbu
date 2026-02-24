import '../../config.dart';

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? image;
  final String? video;
  final String? categoryId;
  final String categoryName;
  final String authorName;
  final String? authorAvatar;
  final List<NewsDocument> documents;
  final int views;
  final DateTime? createdAt;

  final bool isBookmarked;
  final int likes;
  final bool isLiked;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    this.video,
    this.categoryId,
    required this.categoryName,
    required this.authorName,
    this.authorAvatar,
    required this.documents,
    required this.views,
    this.createdAt,
    this.isBookmarked = false,
    this.likes = 0,
    this.isLiked = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',

      // ✅ IMAGE FIX (absolute URL)
      image: _parseMediaUrl(json['image']),
      video: _parseMediaUrl(json['video']),

      categoryId: json['category'] is Map
          ? json['category']['_id']?.toString()
          : json['category']?.toString(),

      categoryName: json['category'] is Map
          ? (json['category']['name'] ?? 'Unknown')
          : (json['category']?.toString() ?? 'Unknown'),

      authorName: (json['author'] is Map)
          ? (json['author']['name'] ?? json['author']['fullName'] ?? 'Unknown')
          : (json['user'] is Map)
          ? (json['user']['name'] ?? json['user']['fullName'] ?? 'Unknown')
          : 'Unknown',

      authorAvatar: (json['author'] is Map)
          ? _parseMediaUrl(json['author']['avatar'])
          : (json['user'] is Map)
          ? _parseMediaUrl(json['user']['avatar'])
          : null,

      documents: json['documents'] is List
          ? (json['documents'] as List)
                .map((doc) => NewsDocument.fromJson(doc))
                .toList()
          : [],

      views: json['views'] is int
          ? json['views']
          : int.tryParse(json['views']?.toString() ?? '0') ?? 0,

      likes: json['likesCount'] is int
          ? json['likesCount']
          : (json['likes'] is List ? (json['likes'] as List).length : 0),

      isLiked: json['isLiked'] ?? false,

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  // ================= HELPERS =================

  static String? _parseMediaUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return AppConfig.transformUrl(value.toString());
  }

  // ================= GETTERS =================

  String get createdAtFormatted {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  String? get category => categoryId;
}

class NewsDocument {
  final String id;
  final String name;
  final String url;

  NewsDocument({required this.id, required this.name, required this.url});

  factory NewsDocument.fromJson(Map<String, dynamic> json) {
    return NewsDocument(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? 'Untitled Document',
      url: NewsModel._parseMediaUrl(json['url']) ?? '',
    );
  }
}
