class Contact {
  String id = '23';
  String name;
  String phone;

  Contact({required this.name, required this.phone, required this.id});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phone: json['phoneNumber'],
      id: json['id'],
    );
  }
}
