// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_device_ports_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicePortsInfo _$DevicePortsInfoFromJson(Map<String, dynamic> json) =>
    DevicePortsInfo(
      size: (json['size'] as num?)?.toInt(),
      ports: (json['ports'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DevicePortsInfoToJson(DevicePortsInfo instance) =>
    <String, dynamic>{'size': instance.size, 'ports': instance.ports};
