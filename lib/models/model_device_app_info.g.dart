// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_device_app_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceAppInfo _$DeviceAppInfoFromJson(Map<String, dynamic> json) =>
    DeviceAppInfo(
      appInstalled: json['appInstalled'] as bool? ?? false,
      appVersion: json['appVersion'] as String? ?? '',
    );

Map<String, dynamic> _$DeviceAppInfoToJson(DeviceAppInfo instance) =>
    <String, dynamic>{
      'appInstalled': instance.appInstalled,
      'appVersion': instance.appVersion,
    };
