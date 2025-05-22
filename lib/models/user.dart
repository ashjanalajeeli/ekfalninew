import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  @JsonKey(defaultValue: '')
  final String avatar;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
} 