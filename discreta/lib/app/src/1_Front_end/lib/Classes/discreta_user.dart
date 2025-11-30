class DiscretaUser {
  final String uid;
  final String firebaseUserId;
  final String firstName;
  final String lastName;
  final String email;

  DiscretaUser({
    required this.uid,
    required this.firebaseUserId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory DiscretaUser.fromJson(Map<String, dynamic> json) {
    return DiscretaUser(
      uid: json['uid'] as String,
      firebaseUserId: json['firebaseUserId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );
  }
}
