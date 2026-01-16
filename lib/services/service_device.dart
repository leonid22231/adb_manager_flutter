import 'dart:io';

import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/services/service_adb.dart';
import 'package:collection/collection.dart';

class ServiceDevice {
  bool _isInit = false;
  bool _syncRunning = false;
  final List<Device> _deviceList = [];
  final List<Function> _listeners = [];
  DateTime? lastUpdate;
  static ServiceDevice instance = ServiceDevice();

  void init() {
    ServiceAdb.instance.init();
    _isInit = true;
  }

  void dispose() {
    _isInit = false;
  }

  ////////////////////////////////////////////////////////
  ///Devices
  void addDevices(List<Device> devices) {
    List<Device> notAddedDevices = [];
    for (Device device in devices) {
      bool isAdded =
          _deviceList.firstWhereOrNull((e) => e.deviceIp == device.deviceIp) !=
          null;

      if (!isAdded) {
        notAddedDevices.add(device);
      }
    }
    _deviceList.addAll(notAddedDevices);
    _notifyListeners();
  }

  void addDevice(Device device) {
    bool isAdded =
        _deviceList.firstWhereOrNull((e) => e.deviceIp == device.deviceIp) !=
        null;
    if (isAdded) return;
    _deviceList.add(device);
    _notifyListeners();
  }

  void removeDevice(Device device) {
    bool isAdded =
        _deviceList.firstWhereOrNull((e) => e.deviceIp == device.deviceIp) !=
        null;
    if (!isAdded) return;
    _deviceList.remove(device);
    _notifyListeners();
  }

  Future<void> syncDevices() async {
    if (_syncRunning) return;
    _syncRunning = true;
    _notifyListeners();
    for (Device device in _deviceList) {
      bool isOnline = await _pingDeviceNetwork(device);
      device.setDeviceOnline(isOnline);
      if (isOnline || device.isEmulator()) {
        bool isAdbConnect = await _pingDeviceAdb(device);

        device.setDeviceAdbConnect(isAdbConnect);
      } else {
        device.setDeviceAdbConnect(false);
      }
    }
    lastUpdate = DateTime.now();
    _notifyListeners();
    _syncRunning = false;
  }

  Future<bool> _pingDeviceNetwork(Device device) async {
    if (device.isEmulator()) return false;

    try {
      ProcessResult result = await Process.run('ping', [device.deviceIp ?? '']);

      String output = result.stdout.toString().toLowerCase();

      bool hasReply =
          output.contains('reply from') ||
          output.contains('bytes=32') ||
          output.contains('ttl=');

      bool noLoss =
          output.contains('lost = 0') ||
          output.contains('(0% loss)') ||
          output.contains('0% loss');

      bool isOnline =
          hasReply && noLoss && !output.contains('request timed out');

      return isOnline;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _pingDeviceAdb(Device device) async {
    return ServiceAdb.instance.deviceIsConnect(device);
  }

  Future<void> updateDevice(String ip, List<String> ports) async {
    Device? device = _deviceList.findByIp(ip);
    if (device == null) {
      return;
    }

    await ServiceAdb.instance.updateDeviceInfo(device, ports);
    _notifyListeners();
  }

  Future<void> connectDevice(Device device) async {
    _syncRunning = true;
    _notifyListeners();
    bool isConnected = await ServiceAdb.instance.connectDevice(device);
    device.setDeviceAdbConnect(isConnected);
    _syncRunning = false;
    _notifyListeners();
  }

  bool isEmpty() => _deviceList.isEmpty;
  int count() => _deviceList.length;
  Device deviceByIndex(int index) => _deviceList[index];

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
  bool get syncRunning => _syncRunning;
}

extension DeviceListExtension on List<Device> {
  Device? findById(int id) {
    return firstWhereOrNull((device) => device.id == id);
  }

  Device? findByIp(String deviceIp) {
    return firstWhereOrNull((device) => device.deviceIp == deviceIp);
  }
}
