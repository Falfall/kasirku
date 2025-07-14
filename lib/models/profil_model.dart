class profil {
  final String id;
  final String email;

  profil({required this.id, required this.email});

  factory profil.fromJson(Map<String, dynamic> json) {
    return profil(id: json['id'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
