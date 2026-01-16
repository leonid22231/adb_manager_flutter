import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/utils/json_serializable_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_device.g.dart';

@JsonSerializable()
class Device extends JsonSerializableModel {
  int id;
  String name;
  String? deviceIp;
  String? devicePort;
  DeviceStatus deviceStatus;
  ConnectStatus connectStatus;
  DeviceType deviceType;
  DateTime createDate;
  DateTime? lastConnectDate;

  Device({required this.name, this.deviceIp, this.devicePort})
    : id = 0,
      deviceStatus = DeviceStatus.offline,
      connectStatus = ConnectStatus.disconnect,
      deviceType = name.contains('emulator')
          ? DeviceType.emulator
          : DeviceType.device,
      createDate = DateTime.now();

  String getAddress() => '$deviceIp:$devicePort';
  
  String getAddressMaybeNotPort() =>
      '$deviceIp${(isEmulator() || devicePort == null) ? '' : ':$devicePort'}';

  void setIpAndPort({required String? ip, required String? port}) {
    deviceIp = ip;
    devicePort = port;
  }

  void setIp({required String ip}) {
    deviceIp = ip;
  }

  void setPort({required String? port}) {
    devicePort = port;
  }

  void setDeviceOnline(DevicePingStatus status) {
    if (status.getStatus() != deviceStatus) {
      deviceStatus = status.getStatus();
      di<ServiceNotifications>().sendDeviceOnlineNotification(this);
    }
  }

  void setDeviceAdbConnect(bool value) {
    if (value) {
      connectStatus = ConnectStatus.connect;
    } else {
      connectStatus = ConnectStatus.disconnect;
    }
  }

  bool isEmulator() => deviceType == DeviceType.emulator;

  bool isConnectAvailable() {
    return isAdbAvailable() && connectStatus == ConnectStatus.disconnect;
  }

  bool isDisconnectAvailable() {
    return isAdbAvailable() && connectStatus == ConnectStatus.connect;
  }

  bool isAdbAvailable() {
    return deviceStatus == DeviceStatus.online &&
        (isEmulator() ? true : devicePort != null);
  }

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

enum ConnectStatus { connect, disconnect }

enum DeviceStatus { online, offline, unstable }

enum DeviceType { device, emulator }
