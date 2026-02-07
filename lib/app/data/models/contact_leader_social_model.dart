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
    if (json == null) return AboutModel(
      id: '',
      title: '',
      logo: '',
      description: '',
      history: '',
      contact: Contact.fromJson(null),
      leaders: [],
      socialLinks: [],
    );

    return AboutModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      history: json['history']?.toString() ?? '',
      contact: Contact.fromJson(json['contact']),
      leaders: (json['leaders'] as List<dynamic>? ?? [])
          .map((e) => Leader.fromJson(e))
          .toList(),
      socialLinks: (json['socialLinks'] as List<dynamic>? ?? [])
          .map((e) => SocialLink.fromJson(e))
          .toList(),
    );
  }
}

class Contact {
  final String email;
  final String phone;
  final String address;
  final String website;

  Contact({required this.email, required this.phone, required this.address, required this.website});

  factory Contact.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Contact(email: '', phone: '', address: '', website: '');
    return Contact(
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
    );
  }

  toJson() {}
}

class Leader {
  final String name;
  final String position;
  final String image;
  final String bio;

  Leader({required this.name, required this.position, required this.image, required this.bio});

  factory Leader.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Leader(name: '', position: '', image: '', bio: '');
    return Leader(
      name: json['name']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
    );
  }

  toJson() {}
}

class SocialLink {
  final String platform;
  final String url;

  SocialLink({required this.platform, required this.url});

  factory SocialLink.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SocialLink(platform: '', url: '');
    return SocialLink(
      platform: json['platform']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  toJson() {}
}
