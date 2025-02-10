import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

@JsonSerializable(
  converters: [
    NullableDateTimeConverter(),
  ],
)
class Reminder {
  final int? id;
  @JsonKey(name: 'todoId')
  final int todoId;
  @JsonKey(name: 'remindAt')
  final DateTime remindAt;
  @JsonKey(name: 'remindType')
  final String remindType; // once/daily/weekly
  @JsonKey(name: 'notifyType')
  final String notifyType; // email/push
  final bool status;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
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
