import '../../config.dart';

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? image;
  final String? video;
  final String categoryName;
  final String authorName;
  final String? authorAvatar;
  final List<NewsDocument> documents;
  final int views;
  final DateTime? createdAt;

  final bool isBookmarked;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    this.video,
    required this.categoryName,
    required this.authorName,
    this.authorAvatar,
    required this.documents,
    required this.views,
    this.createdAt,
    this.isBookmarked = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',

      // ✅ IMAGE FIX (absolute URL)
      image: _parseMediaUrl(json['image']),
      video: _parseMediaUrl(json['video']),

      categoryName: json['category'] is Map
          ? (json['category']['name'] ?? 'Unknown')
          : (json['category']?.toString() ?? 'Unknown'),
      authorName: json['author'] is Map
          ? (json['author']['name'] ?? 'Unknown')
          : 'Unknown',
      authorAvatar: json['author'] is Map
          ? _parseMediaUrl(json['author']['avatar'])
          : null,

      documents: json['documents'] is List
          ? (json['documents'] as List)
                .map((doc) => NewsDocument.fromJson(doc))
                .toList()
          : [],

      views: json['views'] is int
          ? json['views']
          : int.tryParse(json['views']?.toString() ?? '0') ?? 0,

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  // ================= HELPERS =================

  static String? _parseMediaUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    String url = value.toString();
    String originalUrl = url; // Store original for debugging

    // Handle full URLs from backend that contain localhost
    if (url.startsWith('http://localhost:')) {
      // Extract just the path part (e.g., "uploads/media-123.mp4")
      final uri = Uri.parse(url);
      url = uri.path.substring(1); // Remove leading slash
      print('🔧 Stripped localhost URL: $originalUrl → $url');
    }

    // If the URL contains localhost (but not at start), replace it
    if (url.contains('localhost')) {
      url = url.replaceAll('localhost', AppConfig.host);
      print('📝 Replaced localhost: $originalUrl → $url');
    }

    // If the URL is already a full URL (after localhost handling), return it
    if (url.startsWith('http')) {
      print('✅ Full URL detected: $url');
      return url;
    }

    // Otherwise, prepend the base URL
    final fullUrl = '${AppConfig.baseUrl}/$url';
    print('🔗 Constructed URL: $url → $fullUrl');
    return fullUrl;
  }

  // ================= GETTERS =================

  String get createdAtFormatted {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  get category => null;

  get likes => null;
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
