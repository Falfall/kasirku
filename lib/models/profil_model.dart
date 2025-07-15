class Profil {
  final String id;
  final String email;

  Profil({required this.id, required this.email});

  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(id: json['id'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
