// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  body: json['body'] as String?,
  payload: json['payload'] as String?,
  subtitle: json['subtitle'] as String?,
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'subtitle': instance.subtitle,
      'payload': instance.payload,
    };
