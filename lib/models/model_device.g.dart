// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) =>
    Device(
        name: json['name'] as String,
        deviceIp: json['deviceIp'] as String?,
        devicePort: json['devicePort'] as String?,
      )
      ..id = (json['id'] as num).toInt()
      ..deviceStatus = $enumDecode(_$DeviceStatusEnumMap, json['deviceStatus'])
      ..connectStatus = $enumDecode(
        _$ConnectStatusEnumMap,
        json['connectStatus'],
      )
      ..deviceType = $enumDecode(_$DeviceTypeEnumMap, json['deviceType'])
      ..createDate = DateTime.parse(json['createDate'] as String)
      ..lastConnectDate = json['lastConnectDate'] == null
          ? null
          : DateTime.parse(json['lastConnectDate'] as String);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'deviceIp': instance.deviceIp,
  'devicePort': instance.devicePort,
  'deviceStatus': _$DeviceStatusEnumMap[instance.deviceStatus]!,
  'connectStatus': _$ConnectStatusEnumMap[instance.connectStatus]!,
  'deviceType': _$DeviceTypeEnumMap[instance.deviceType]!,
  'createDate': instance.createDate.toIso8601String(),
  'lastConnectDate': instance.lastConnectDate?.toIso8601String(),
};

const _$DeviceStatusEnumMap = {
  DeviceStatus.online: 'online',
  DeviceStatus.ofline: 'ofline',
};

const _$ConnectStatusEnumMap = {
  ConnectStatus.connect: 'connect',
  ConnectStatus.disconnect: 'disconnect',
};

const _$DeviceTypeEnumMap = {
  DeviceType.device: 'device',
  DeviceType.emulator: 'emulator',
};
