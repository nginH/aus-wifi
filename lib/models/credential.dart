class Credential {
  final int? id;
  final String username;
  final String password;
  final bool isActive;

  Credential({
    this.id,
    required this.username,
    required this.password,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Credential.fromMap(Map<String, dynamic> map) {
    return Credential(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      isActive: map['isActive'] == 1,
    );
  }

  Credential copyWith({
    int? id,
    String? username,
    String? password,
    bool? isActive,
  }) {
    return Credential(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
    );
  }
}
