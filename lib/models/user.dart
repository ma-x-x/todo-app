import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// 用户模型
@JsonSerializable()
class User {
  /// 用户ID
  final int? id;

  /// 用户名
  final String username;

  /// 电子邮箱
  final String email;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
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
