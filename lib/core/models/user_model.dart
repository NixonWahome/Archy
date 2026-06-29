/// User model for authentication
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'architect', 'diaspora', 'developer'
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'architect',
      photoUrl: map['photoUrl'],
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
