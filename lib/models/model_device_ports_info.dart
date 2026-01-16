import 'package:json_annotation/json_annotation.dart';

part 'model_device_ports_info.g.dart';

@JsonSerializable()
class DevicePortsInfo {
  int size;
  List<String> ports;

  DevicePortsInfo({int? size, List<String>? ports})
    : size = size ?? 0,
      ports = ports ?? [];


  factory DevicePortsInfo.fromJson(Map<String, dynamic> json) => _$DevicePortsInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DevicePortsInfoToJson(this);
}
