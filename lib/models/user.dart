import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
} 