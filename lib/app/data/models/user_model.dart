import '../../config.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatar;
  final String? bio;
  final String? gender;
  final UserSettings settings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.avatar,
    this.bio,
    this.gender,
    required this.settings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse _id
    final id = json['_id'] is Map
        ? json['_id'][r'$oid'] ?? ''
        : json['_id']?.toString() ?? '';

    // Parse createdAt
    DateTime parseDate(dynamic value) {
      if (value is Map && value.containsKey(r'$date')) {
        return DateTime.tryParse(value[r'$date'].toString()) ?? DateTime.now();
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final createdAt = parseDate(json['createdAt']);
    final updatedAt = parseDate(json['updatedAt']);

    // Parse settings
    final settingsData = json['settings'] as Map<String, dynamic>?;
    final settings = settingsData != null
        ? UserSettings.fromJson(settingsData)
        : UserSettings();

    return UserModel(
      id: id,
      name: json['name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: createdAt,
      updatedAt: updatedAt,
      avatar: AppConfig.transformUrl(json['avatar']),
      bio: json['bio'],
      gender: json['gender'],
      settings: settings,
    );
  }

  // Optional: formatted dates
  String get createdAtFormatted =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get updatedAtFormatted =>
      '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
}

class UserSettings {
  final bool darkMode;
  final bool emailNotifications;
  final bool pushNotifications;
  final String language;

  UserSettings({
    this.darkMode = false,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.language = 'English',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      darkMode: json['darkMode'] ?? false,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      language: json['language'] ?? 'English',
    );
  }

  Map<String, dynamic> toJson() => {
    'darkMode': darkMode,
    'emailNotifications': emailNotifications,
    'pushNotifications': pushNotifications,
    'language': language,
  };
}
