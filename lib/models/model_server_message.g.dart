// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_server_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerMessage _$ServerMessageFromJson(Map<String, dynamic> json) =>
    ServerMessage(
      type: $enumDecode(_$ServerMessageTypeEnumMap, json['type']),
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$ServerMessageToJson(ServerMessage instance) =>
    <String, dynamic>{
      'type': _$ServerMessageTypeEnumMap[instance.type]!,
      'message': instance.message,
    };

const _$ServerMessageTypeEnumMap = {ServerMessageType.appstart: 'appstart'};
