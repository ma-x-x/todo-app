import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int? id;
  final String name;
  final String? color;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Category({
    this.id,
    required this.name,
    this.color,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
} 