import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/models/model_device_app_info.dart';
import 'package:adb_manager/models/model_server_message.dart';
import 'package:adb_manager/services/interface/service_device_interface.dart';
import 'package:adb_manager/services/service_adb.dart';
import 'package:adb_manager/utils/tools_storage.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';

class ServiceDevice implements ServiceDeviceInterface {
  String cacheKey = 'ServiceDevice.cache';
  final GetIt di;
  ServiceDevice(this.di);

  bool _isInit = false;
  bool _syncRunning = false;
  final List<Device> _deviceList = [];
  final List<SendPort> _listeners = [];
  DateTime? _lastUpdate;

  Future<void> init() async {
    if (_isInit) return;
    await _loadDevices();
    di<ServiceAdb>().init();
    _isInit = true;
  }

  void dispose() {
    _isInit = false;
  }

  ////////////////////////////////////////////////////////
  ///Devices
  @override
  Future<void> addDevices(List<Device> devices) async {
    List<Device> notAddedDevices = [];
    for (Device device in List.of(devices)) {
      bool isAdded =
          _deviceList.firstWhereOrNull((e) => e.deviceIp == device.deviceIp) !=
          null;

      if (!isAdded) {
        notAddedDevices.add(device);
      }
    }
    _deviceList.addAll(notAddedDevices);
    _notifyListeners();
    syncDevices();
  }

  @override
  Future<void> addDevice(Device device) async {
    bool isAdded =
        _deviceList.firstWhereOrNull((e) => e.deviceIp == device.deviceIp) !=
        null;
    if (isAdded) return;
    _deviceList.add(device);
    _notifyListeners();
    _notifyDeviceAppStarted(device);
  }

  @override
  Future<void> removeDevice(Device device) async {
    bool isAdded =
        _deviceList.firstWhereOrNull((e) => e.deviceIp == device.deviceIp) !=
        null;
    if (!isAdded) return;
    _deviceList.remove(device);
    _notifyListeners();
  }

  @override
  Future<void> syncDevices() async {
    if (_syncRunning) return;
    _syncRunning = true;
    _notifyListeners();
    for (Device device in List.of(_deviceList)) {
      DevicePingStatus pingStatus = await _pingDeviceNetwork(device);
      if (pingStatus.isOnline &&
          !device.isEmulator() &&
          device.lastUpdateDate == null) {
        _notifyDeviceAppStarted(device);
      }
      device.setDeviceOnline(pingStatus);
      if (pingStatus.isOnline || device.isEmulator()) {
        bool isAdbConnect = await _pingDeviceAdb(device);

        device.setDeviceAdbConnect(isAdbConnect);
      } else {
        device.setDeviceAdbConnect(false);
      }

      _notifyListeners();
    }
    _lastUpdate = DateTime.now();
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

  @override
  Future<void> updateDevice(String ip, List<String> ports) async {
    Device? device = _deviceList.findByIp(ip);
    if (device == null) {
      return;
    }

    await di<ServiceAdb>().updateDeviceInfo(device, ports);

    _notifyListeners();

    syncDevices();
  }

  @override
  Future<void> updateDeviceAppInfo(String ip, ServerMessage message) async {
    Device? device = _deviceList.findByIp(ip);
    if (device == null) {
      return;
    }

    device.deviceAppInfo = DeviceAppInfo(
      appInstalled: true,
      appVersion: message.message,
    );

    _notifyListeners();
  }

  @override
  Future<void> connectDevice(Device device) async {
    _syncRunning = true;
    _notifyListeners();
    bool isConnected = await di<ServiceAdb>().connectDevice(device);
    device.setDeviceAdbConnect(isConnected);
    _syncRunning = false;
    _notifyListeners();
  }

  @override
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

  @override
  Future<bool> isEmpty() => Future.value(_deviceList.isEmpty);

  @override
  Future<int> count() => Future.value(_deviceList.length);

  @override
  Future<Device> deviceByIndex(int index) => Future.value(_deviceList[index]);

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

    _notifyDevicesAppStarted();
  }

  Future<void> _notifyDevicesAppStarted() async {
    for (Device device in _deviceList) {
      await _notifyDeviceAppStarted(device);
    }
  }

  Future<bool> _notifyDeviceAppStarted(Device device) async {
    if (device.isEmulator()) return false;

    bool appInstalled = false;
    try {
      final socket = await Socket.connect(device.deviceIp, 41174);
      log('✅ Подключено: ${socket.remoteAddress.address}:${socket.remotePort}');
      appInstalled = true;

      ServerMessage message = ServerMessage(type: ServerMessageType.appstart);
      final bytes = utf8.encode(message.toJsonString());

      socket.add(bytes);

      await socket.flush();

      socket.destroy();
    } catch (e) {
      log('Error send appStarted $e');
      appInstalled = false;
    }

    return appInstalled;
  }

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
    _updateSavedDevices();
    for (SendPort port in _listeners) {
      port.send('');
    }
  }

  ///
  ////////////////////////////////////////////////////////

  bool get isInit => _isInit;

  @override
  Future<DateTime?> get lastUpdate => Future.value(_lastUpdate);

  @override
  Future<bool> get syncRunning => Future.value(_syncRunning);
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
