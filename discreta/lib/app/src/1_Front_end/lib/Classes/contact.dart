class Contact {
  String? id;
  String name;
  String phone;

  Contact({required this.name, required this.phone});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(name: json['name'], phone: json['phoneNumber'])
      ..id = json['id'];
  }
}
