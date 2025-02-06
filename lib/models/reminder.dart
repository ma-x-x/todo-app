import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

@JsonSerializable()
class Reminder {
  final int? id;
  final int todoId;
  final DateTime remindAt;
  final String remindType; // once/daily/weekly
  final String notifyType; // email/push
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
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
}
