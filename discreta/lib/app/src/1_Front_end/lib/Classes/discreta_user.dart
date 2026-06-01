class DiscretaUser {
  final String uid;
  final String firstName;
  final String email;
  String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiscretaUser({
    required this.uid,
    required this.firstName,
    required this.email,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscretaUser.fromJson(Map<String, dynamic> json) {
    return DiscretaUser(
      uid: json['uid'] as String,
      firstName: json['first_name'] as String,
      email: json['email'] as String,
      language: json['language'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
