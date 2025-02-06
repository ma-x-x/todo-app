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
      createdAt: const NullableDateTimeConverter()
          .fromJson(json['createdAt'] as String?),
      updatedAt: const NullableDateTimeConverter()
          .fromJson(json['updatedAt'] as String?),
      deletedAt: const NullableDateTimeConverter()
          .fromJson(json['deletedAt'] as String?),
    );

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
      'id': instance.id,
      'todoId': instance.todoId,
      'remindAt': instance.remindAt.toIso8601String(),
      'remindType': instance.remindType,
      'notifyType': instance.notifyType,
      'status': instance.status,
      'createdAt': const NullableDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const NullableDateTimeConverter().toJson(instance.updatedAt),
      'deletedAt': const NullableDateTimeConverter().toJson(instance.deletedAt),
    };
