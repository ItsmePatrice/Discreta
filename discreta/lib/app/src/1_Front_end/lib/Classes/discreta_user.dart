class DiscretaUser {
  final String uid;
  final String firebaseUserId;
  final String firstName;
  final String lastName;
  final String email;
  final bool isSubscribed;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiscretaUser({
    required this.uid,
    required this.firebaseUserId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isSubscribed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscretaUser.fromJson(Map<String, dynamic> json) {
    return DiscretaUser(
      uid: json['uid'] as String,
      firebaseUserId: json['firebase_user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      isSubscribed: json['is_subscribed'] as bool,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
