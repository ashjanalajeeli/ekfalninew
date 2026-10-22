import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String email;
  final String name;
  final String fullName;
  final String password;
  final String? profileImage;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.fullName,
    required this.password,
    this.profileImage,
    this.role = 'donor',

  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? fullName,
    String? password,
    String? profileImage,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'fullName': fullName,
      'profileImage': profileImage,
      'role': role,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      fullName: json['fullName'] as String,
      password: json['password'],
      profileImage: json['profileImage'] as String?,
      role: json['role'] as String? ?? 'donor',
    );
  }

  bool get isAdmin => role == 'admin' || role == 'supervisor';
}
