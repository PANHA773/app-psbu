class AnnouncementModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AnnouncementSender sender;

  AnnouncementModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['sender'];
    final senderMap = senderRaw is Map<String, dynamic>
        ? senderRaw
        : senderRaw is Map
        ? Map<String, dynamic>.from(senderRaw)
        : <String, dynamic>{};

    return AnnouncementModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      sender: AnnouncementSender.fromJson(senderMap),
    );
  }
}

class AnnouncementSender {
  final String id;
  final String name;
  final String role;

  AnnouncementSender({
    required this.id,
    required this.name,
    required this.role,
  });

  factory AnnouncementSender.fromJson(Map<String, dynamic> json) {
    return AnnouncementSender(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      role: json['role']?.toString() ?? 'user',
    );
  }
}
