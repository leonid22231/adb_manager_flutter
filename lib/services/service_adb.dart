import 'dart:io';
import 'dart:isolate';

import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/services/interface/service_adb_interface.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';

class ServiceAdb extends ServiceAdbInterface {
  final GetIt di;

  ServiceAdb(this.di);

  bool _isInit = false;
  bool _adbAvailable = false;
  ServiceAdbState? state;
  final List<SendPort> _listeners = [];

  void init() async {
    _isInit = true;
    await syncAdbStatus();
    updateState();
  }

  void dispose() {
    _isInit = false;
  }

  Future<void> syncAdbStatus() async {
    _adbAvailable = await _checkAdbAvailability();
    _notifyListeners();
  }

  Future<void> syncAdbDevices() async {
    if (!_adbAvailable) return;
    List<Device> devices = await _getAdbDevices();
    di<ServiceDevice>().addDevices(devices);
  }

  ////////////////////////////////////////////////////////
  ///ADB

  Future<bool> deviceIsConnect(Device device) async {
    await updateState();
    Device? tempDevice = state!.devices.firstWhereOrNull(
      (e) => e.deviceIp == device.deviceIp,
    );
    bool isConnect = tempDevice != null;

    if (isConnect) {
      device.setIpAndPort(ip: tempDevice.deviceIp, port: tempDevice.devicePort);
    }

    return isConnect;
  }

  Future<void> updateState({bool forceUpdate = false}) async {
    if (!_adbAvailable) return;

    bool needUpdate =
        state == null ||
        DateTime.now().difference(state!.lastUpdate).inSeconds >= 5 ||
        forceUpdate;

    if (!needUpdate) return;

    List<Device> devices = await _getAdbDevices();

    state = ServiceAdbState(lastUpdate: DateTime.now(), devices: devices);
  }

  Future<bool> _checkAdbAvailability() async {
    try {
      ProcessResult result = await Process.run('adb', ['version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<Device>> _getAdbDevices() async {
    List<Device> devices = [];
    try {
      ProcessResult result = await Process.run('adb', ['devices']);
      List<String> lines = (result.stdout as String).split('\n');
      lines.removeAt(0);
      List<String> stringDevicesName = lines
          .where((line) => line.contains('device'))
          .map((line) => line.trim().split('\t')[0])
          .toList();

      for (String deviceString in stringDevicesName) {
        bool needGetIp =
            deviceString.contains('_adb-tls-connect') &&
                deviceString.contains('_tcp') ||
            !_isValidIPv4(deviceString);

        Device device = Device(name: deviceString);
        if (!device.isEmulator()) {
          String ip = needGetIp ? '' : device.name.split(':')[0];
          String port = needGetIp ? '' : device.name.split(':')[1];
          if (needGetIp) {
            ip = await _getDeviceIp(device.name) ?? ip;
            port = port;
          }
          device.setIpAndPort(ip: ip, port: port);
        } else {
          device.setIp(ip: deviceString);
        }

        devices.add(device);
      }
      return devices;
    } catch (e) {
      return devices;
    }
  }

  Future<Device> updateDeviceInfo(Device device, List<String> ports) async {
    for (String port in ports) {
      bool isCorrect = await _checkIpAndPortAvailable(device.deviceIp!, port);
      if (isCorrect) {
        device.setIpAndPort(ip: device.deviceIp, port: port);
        return device;
      }
    }
    return device;
  }

  Future<String?> _getDeviceIp(String deviceId) async {
    ProcessResult result = await Process.run('adb', [
      '-s',
      deviceId,
      'shell',
      'ip',
      'addr',
      'show',
      'wlan0',
    ]);
    RegExp ipRegex = RegExp(r'(\d+\.\d+\.\d+\.\d+)');
    Match? match = ipRegex.firstMatch(result.stdout);
    return match?.group(1);
  }

  bool _isValidIPv4(String ip) {
    if (ip.isEmpty) return false;
    String tempIp = ip;
    if (tempIp.contains(':')) {
      tempIp = tempIp.split(':')[0];
    }
    final parts = tempIp.split('.');
    if (parts.length != 4) return false;

    for (String part in parts) {
      if (part.isEmpty) return false;
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
  }

  Future<bool> connectDevice(Device device) async {
    try {
      String address = device.getAddress();
      ProcessResult result = await Process.run('adb', ['connect', address]);
      String resultString = result.stdout;
      if (resultString.contains('cannot connect to')) {
        device.setPort(port: null);
        di<ServiceNotifications>().sendDeviceAdbNotConnect(device);
        return false;
      }
      if (resultString.contains('already connected to')) {
        return true;
      }
      if (resultString.contains('connected to')) {
        return true;
      }
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> disconnectDevice(Device device) async {
    try {
      String address = device.getAddress();
      ProcessResult result = await Process.run('adb', ['disconnect', address]);
      String resultString = result.stdout;
      if (resultString.contains('error: no such device')) {
        return true;
      }
      if (resultString.contains('disconnected $address')) {
        return false;
      }
      return result.exitCode == 0;
    } catch (e) {
      return true;
    }
  }
  //'connected to'
  //'already connected to'
  //'cannot connect to'
  //

  Future<bool> _checkIpAndPortAvailable(String ip, String port) async {
    try {
      String address = '$ip:$port';
      ProcessResult result = await Process.run('adb', ['connect', address]);
      String resultString = result.stdout;
      if (resultString.contains('cannot connect to')) {
        return false;
      }
      if (resultString.contains('already connected to')) {
        return true;
      }
      if (resultString.contains('connected to')) {
        await Process.run('adb', ['disconnect', address]);
        return true;
      }
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  ///
  ////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////
  ///Listeners
  @override
  void addListener(SendPort port) {
    _listeners.add(port);
  }

  @override
  void removeListener(SendPort port) {
    _listeners.remove(port);
  }

  void _notifyListeners() {
    for (SendPort port in _listeners) {
      port.send('');
    }
  }

  ///
  ////////////////////////////////////////////////////////

  bool get isInit => _isInit;

  @override
  Future<bool> get adbAvailable => Future.value(_adbAvailable);
}

class ServiceAdbState {
  DateTime lastUpdate;
  List<Device> devices;

  ServiceAdbState({required this.lastUpdate, this.devices = const []});
}
