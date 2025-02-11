import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// 待办事项分类模型
@JsonSerializable()
class Category {
  /// 分类ID
  final int id;

  /// 分类名称
  final String name;

  /// 分类描述
  final String? description;

  /// 分类颜色
  final String? color;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
