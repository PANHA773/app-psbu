import '../../config.dart';

class StoryUser {
  final String id;
  final String name;
  final String? avatar;

  StoryUser({required this.id, required this.name, this.avatar});

  factory StoryUser.fromAny(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return StoryUser.fromJson(raw);
    }
    if (raw is Map) {
      return StoryUser.fromJson(Map<String, dynamic>.from(raw));
    }
    return StoryUser(id: raw?.toString() ?? '', name: '');
  }

  factory StoryUser.fromJson(Map<String, dynamic> json) {
    return StoryUser(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: _asText(json['name'] ?? json['fullName'] ?? json['username']),
      avatar: _parseAvatarUrl(json['avatar']),
    );
  }

  static String? _parseAvatarUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return AppConfig.transformUrl(value.toString());
  }

  static String _asText(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class StoryModel {
  final String id;
  final StoryUser user;
  final String image;
  final String video;
  final String caption;
  final int viewerCount;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  StoryModel({
    required this.id,
    required this.user,
    required this.image,
    this.video = '',
    required this.caption,
    this.viewerCount = 0,
    this.expiresAt,
    this.createdAt,
  });

  bool get hasVideo => video.isNotEmpty || _looksLikeVideoUrl(image);
  String get mediaUrl => video.isNotEmpty ? video : image;

  factory StoryModel.fromAny(dynamic raw) {
    if (raw is StoryModel) return raw;
    if (raw is Map<String, dynamic>) return StoryModel.fromJson(raw);
    if (raw is Map) return StoryModel.fromJson(Map<String, dynamic>.from(raw));
    throw const FormatException('Invalid story payload');
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final mediaType = (json['mediaType'] ?? json['type'] ?? '')
        .toString()
        .toLowerCase();

    String imageUrl = _parseMediaUrl(
      json['image'] ?? json['media'] ?? json['file'] ?? json['url'],
    );
    String videoUrl = _parseMediaUrl(
      json['video'] ?? json['videoUrl'] ?? json['videoPath'],
    );

    if (videoUrl.isEmpty &&
        mediaType.contains('video') &&
        imageUrl.isNotEmpty) {
      videoUrl = imageUrl;
    }

    if (videoUrl.isEmpty && _looksLikeVideoUrl(imageUrl)) {
      videoUrl = imageUrl;
    }

    return StoryModel(
      id: json['_id']?.toString() ?? '',
      user: StoryUser.fromAny(json['user']),
      image: imageUrl,
      video: videoUrl,
      caption: _asText(json['caption']),
      viewerCount: _parseViewerCount(json),
      expiresAt: _parseDate(json['expiresAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static String _parseMediaUrl(dynamic value) {
    if (value == null || value.toString().isEmpty) return '';
    return AppConfig.transformUrl(value.toString());
  }

  static String _asText(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static int _parseViewerCount(Map<String, dynamic> json) {
    final direct = json['viewerCount'] ?? json['views'] ?? json['viewCount'];
    if (direct is num) return direct.toInt();
    if (direct is int) return direct;
    if (direct is List) return direct.length;
    if (direct is Map) {
      final nested = direct['count'] ?? direct['total'] ?? direct['length'];
      if (nested is num) return nested.toInt();
      if (nested != null) {
        final parsedNested = int.tryParse(nested.toString());
        if (parsedNested != null) return parsedNested;
      }
    }
    if (direct != null) {
      final parsed = int.tryParse(direct.toString());
      if (parsed != null) return parsed;
    }

    final viewers = json['viewers'] ?? json['seenBy'] ?? json['viewedBy'];
    if (viewers is List) return viewers.length;
    return 0;
  }

  static bool _looksLikeVideoUrl(String value) {
    if (value.isEmpty) return false;
    final lower = value.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m3u8');
  }
}
