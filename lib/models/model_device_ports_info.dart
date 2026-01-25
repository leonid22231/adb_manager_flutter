import 'package:adb_manager/utils/json_serializable_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_device_ports_info.g.dart';

@JsonSerializable()
class DevicePortsInfo extends JsonSerializableModel {
  int size;
  List<String> ports;

  DevicePortsInfo({required this.size, required this.ports});

  factory DevicePortsInfo.fromJson(Map<String, dynamic> json) =>
      _$DevicePortsInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DevicePortsInfoToJson(this);
}
