import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/services/service_adb.dart';
import 'package:adb_manager/utils/tools_storage.dart';
import 'package:collection/collection.dart';

class ServiceDevice {
  String cacheKey = 'ServiceDevice.cache';

  bool _isInit = false;
  bool _syncRunning = false;
  final List<Device> _deviceList = [];
  final List<Function> _listeners = [];
  DateTime? lastUpdate;

  void init() async {
    await _loadDevices();
    di<ServiceAdb>().init();
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
      DevicePingStatus pingStatus = await _pingDeviceNetwork(device);
      device.setDeviceOnline(pingStatus);
      if (pingStatus.isOnline || device.isEmulator()) {
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

  Future<DevicePingStatus> _pingDeviceNetwork(Device device) async {
    if (device.isEmulator()) return DevicePingStatus(isOnline: true);

    try {
      ProcessResult result = await Process.run('ping', [device.deviceIp ?? '']);

      String output = result.stdout.toString().toLowerCase();

      int? lossPercent;

      bool hasReply =
          output.contains('reply from') ||
          output.contains('bytes=32') ||
          output.contains('ttl=');

      log(output);

      final lossPercentMatch = RegExp(r'\((\d+)% loss\)').firstMatch(output);

      if (lossPercentMatch != null) {
        lossPercent = int.tryParse(lossPercentMatch.group(1) ?? '');
      }

      bool isOnline = hasReply && lossPercent != null;

      return DevicePingStatus(isOnline: isOnline, lossPercent: lossPercent);
    } catch (e) {
      return DevicePingStatus(isOnline: false);
    }
  }

  Future<bool> _pingDeviceAdb(Device device) async {
    return di<ServiceAdb>().deviceIsConnect(device);
  }

  Future<void> updateDevice(String ip, List<String> ports) async {
    Device? device = _deviceList.findByIp(ip);
    if (device == null) {
      return;
    }

    await di<ServiceAdb>().updateDeviceInfo(device, ports);
    _notifyListeners();
  }

  Future<void> connectDevice(Device device) async {
    _syncRunning = true;
    _notifyListeners();
    bool isConnected = await di<ServiceAdb>().connectDevice(device);
    device.setDeviceAdbConnect(isConnected);
    _syncRunning = false;
    _notifyListeners();
  }

  Future<void> disconnectDevice(Device device) async {
    _syncRunning = true;
    _notifyListeners();
    bool isConnected = await di<ServiceAdb>().disconnectDevice(device);
    device.setDeviceAdbConnect(isConnected);
    _syncRunning = false;
    _notifyListeners();
  }

  void showDialogDeviceOnline(DeviceStatus status) {}

  void clear() {
    di<ToolsStorage>().clear();
    _deviceList.clear();
    _notifyListeners();
  }

  bool isEmpty() => _deviceList.isEmpty;
  int count() => _deviceList.length;
  Device deviceByIndex(int index) => _deviceList[index];

  ///
  ////////////////////////////////////////////////////////

  void _updateSavedDevices() {
    List<Device> tempDevices = List.of(_deviceList);

    String jsonString =
        '[${tempDevices.map((e) => e.toJsonString()).join(',')}]';

    di<ToolsStorage>().putString(cacheKey, jsonString);
  }

  Future<void> _loadDevices() async {
    List<Device> cachedDevices = [];

    String jsonString = di<ToolsStorage>().getString(cacheKey);

    if (jsonString.isEmpty) {
      return;
    }

    try {
      dynamic json = jsonDecode(jsonString);
      for (dynamic value in json) {
        Device device = Device.fromJson(value);
        cachedDevices.add(device);
      }

      _deviceList.addAll(cachedDevices);
    } catch (e) {
      //ignore
    }
  }

  ////////////////////////////////////////////////////////
  ///Listeners
  void addListener(Function fnc) {
    _listeners.add(fnc);
  }

  void removeListener(Function fnc) {
    _listeners.remove(fnc);
  }

  void _notifyListeners() {
    _updateSavedDevices();
    for (Function fnc in _listeners) {
      fnc.call();
    }
  }

  ///
  ////////////////////////////////////////////////////////

  bool get isInit => _isInit;
  bool get syncRunning => _syncRunning;
}

class DevicePingStatus {
  bool isOnline;
  int? lossPercent;

  DevicePingStatus({required this.isOnline, this.lossPercent});

  DeviceStatus getStatus() {
    if (!isOnline) {
      return DeviceStatus.offline;
    }
    if (isOnline) {
      if (lossPercent != null) {
        if (lossPercent! >= 50) {
          return DeviceStatus.unstable;
        } else {
          return DeviceStatus.online;
        }
      }
    }

    return DeviceStatus.offline;
  }
}

extension DeviceListExtension on List<Device> {
  Device? findById(int id) {
    return firstWhereOrNull((device) => device.id == id);
  }

  Device? findByIp(String deviceIp) {
    return firstWhereOrNull((device) => device.deviceIp == deviceIp);
  }
}
