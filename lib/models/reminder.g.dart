// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => Reminder(
      id: (json['id'] as num?)?.toInt(),
      todoId: (json['todoId'] as num).toInt(),
      remindAt: DateTime.parse(json['remindAt'] as String),
      remindType: json['remindType'] as String,
      notifyType: json['notifyType'] as String,
      status: json['status'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
      'id': instance.id,
      'todoId': instance.todoId,
      'remindAt': instance.remindAt.toIso8601String(),
      'remindType': instance.remindType,
      'notifyType': instance.notifyType,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
