import 'dart:developer';
import 'dart:io';

import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:collection/collection.dart';

class ServiceAdb {
  bool _isInit = false;
  bool _adbAvailable = false;
  ServiceAdbState? state;
  final List<Function> _listeners = [];

  static ServiceAdb instance = ServiceAdb();

  void init() async {
    _isInit = true;
    await syncAdbStatus();
    _updateState();
  }

  void dispose() {
    _isInit = false;
  }

  Future<void> syncAdbStatus() async {
    _adbAvailable = await _checkAdbAvailability();
    _notifyListeners();
  }

  void syncAdbDevices() async {
    if (!_adbAvailable) return;
    List<Device> devices = await _getAdbDevices();
    ServiceDevice.instance.addDevices(devices);
  }

  ////////////////////////////////////////////////////////
  ///ADB

  Future<bool> deviceIsConnect(Device device) async {
    await _updateState();
    Device? tempDevice = state!.devices.firstWhereOrNull(
      (e) => e.deviceIp == device.deviceIp,
    );
    bool isConnect = tempDevice != null;

    if (isConnect) {
      device.setIpAndPort(ip: tempDevice.deviceIp, port: tempDevice.devicePort);
    }

    return isConnect;
  }

  Future<void> _updateState() async {
    if (!_adbAvailable) return;

    bool needUpdate =
        state == null ||
        DateTime.now().difference(state!.lastUpdate).inSeconds >= 5;

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
  void addListener(Function fnc) {
    _listeners.add(fnc);
  }

  void removeListener(Function fnc) {
    _listeners.remove(fnc);
  }

  void _notifyListeners() {
    for (Function fnc in _listeners) {
      fnc.call();
    }
  }

  ///
  ////////////////////////////////////////////////////////

  bool get isInit => _isInit;
  bool get adbAvailable => _adbAvailable;
}

class ServiceAdbState {
  DateTime lastUpdate;
  List<Device> devices;

  ServiceAdbState({required this.lastUpdate, this.devices = const []});
}
