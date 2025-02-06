import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

@JsonSerializable()
class Reminder {
  final int? id;
  @JsonKey(name: 'todo_id')
  final int todoId;
  @JsonKey(name: 'remind_at')
  final DateTime remindAt;
  @JsonKey(name: 'remind_type')
  final String remindType; // once/daily/weekly
  @JsonKey(name: 'notify_type')
  final String notifyType; // email/push
  final bool status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  Reminder({
    this.id,
    required this.todoId,
    required this.remindAt,
    required this.remindType,
    required this.notifyType,
    this.status = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  Map<String, dynamic> toRequestJson() => {
        'todoId': todoId,
        'remindAt': remindAt.toUtc().toIso8601String(),
        'remindType': remindType,
        'notifyType': notifyType,
        'status': status,
      };
}
