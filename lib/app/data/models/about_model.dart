// about_model.dart
import 'contact_leader_social_model.dart';

class AboutModel {
  final String id;
  final String title;
  final String logo;
  final String description;
  final String history;
  final Contact contact;
  final List<Leader> leaders;
  final List<SocialLink> socialLinks;

  AboutModel({
    required this.id,
    required this.title,
    required this.logo,
    required this.description,
    required this.history,
    required this.contact,
    required this.leaders,
    required this.socialLinks,
  });

  factory AboutModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AboutModel(
        id: '',
        title: '',
        logo: '',
        description: '',
        history: '',
        contact: Contact(email: '', phone: '', address: '', website: ''),
        leaders: [],
        socialLinks: [],
      );
    }

    return AboutModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      history: json['history']?.toString() ?? '',
      contact: Contact.fromJson(json['contact'] as Map<String, dynamic>?),
      leaders: (json['leaders'] as List<dynamic>? ?? [])
          .map((e) => Leader.fromJson(e as Map<String, dynamic>?))
          .toList(),
      socialLinks: (json['socialLinks'] as List<dynamic>? ?? [])
          .map((e) => SocialLink.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'logo': logo,
    'description': description,
    'history': history,
    'contact': contact.toJson(),
    'leaders': leaders.map((e) => e.toJson()).toList(),
    'socialLinks': socialLinks.map((e) => e.toJson()).toList(),
  };
}
