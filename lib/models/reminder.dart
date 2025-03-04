import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

/// 提醒事项模型
@JsonSerializable(
  converters: [
    NullableDateTimeConverter(),
  ],
)
class Reminder {
  /// 提醒ID
  final int? id;

  /// 关联的待办事项ID
  @JsonKey(name: 'todoId')
  final int todoId;

  /// 提醒时间
  @JsonKey(name: 'remindAt')
  final DateTime remindAt;

  /// 提醒类型：一次性/每日/每周
  @JsonKey(name: 'remindType')
  final String remindType;

  /// 通知类型：邮件/推送
  @JsonKey(name: 'notifyType')
  final String notifyType;

  /// 提醒状态
  final bool status;

  /// 创建时间
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  /// 更新时间
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  /// 删除时间
  @JsonKey(name: 'deletedAt')
  final DateTime? deletedAt;

  Reminder({
    this.id,
    required this.todoId,
    required this.remindAt,
    required this.remindType,
    required this.notifyType,
    this.status = false,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as int,
      todoId: json['todoId'] as int,
      remindAt: DateTime.parse(json['remindAt'] as String),
      remindType: json['remindType'] as String,
      notifyType: json['notifyType'] as String,
      status: json['status'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  Map<String, dynamic> toRequestJson() {
    return {
      'todoId': todoId,
      'remindAt': remindAt.toUtc().toIso8601String(),
      'remindType': remindType,
      'notifyType': notifyType,
    };
  }

  Reminder copyWith({
    int? id,
    int? todoId,
    DateTime? remindAt,
    String? remindType,
    String? notifyType,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      remindAt: remindAt ?? this.remindAt,
      remindType: remindType ?? this.remindType,
      notifyType: notifyType ?? this.notifyType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) =>
      json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? json) => json?.toIso8601String();
}
