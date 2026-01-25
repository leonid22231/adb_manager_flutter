import 'package:adb_manager/utils/json_serializable_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_device_app_info.g.dart';

@JsonSerializable()
class DeviceAppInfo extends JsonSerializableModel {
  bool appInstalled = false;
  String appVersion;

  DeviceAppInfo({this.appInstalled = false, this.appVersion = ''});

  factory DeviceAppInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceAppInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DeviceAppInfoToJson(this);
}
