import 'dart:async';
import 'dart:isolate';

import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/models/model_server_message.dart';
import 'package:adb_manager/utils/task_queue.dart';

abstract class ServiceDeviceInterface {
  Future<void> addDevices(List<Device> devices);
  Future<void> addDevice(Device device);
  Future<void> removeDevice(Device device);
  Future<void> syncDevices();
  Future<void> updateDevice(String ip, List<String> ports);
  Future<void> updateDeviceAppInfo(String ip, ServerMessage message);
  Future<void> connectDevice(Device device);
  Future<void> disconnectDevice(Device device);
  void addListener(SendPort fnc);
  void removeListener(SendPort fnc);
  Future<bool> get syncRunning;
  Future<DateTime?> get lastUpdate;
  Future<bool> isEmpty();
  Future<int> count();
  Future<Device> deviceByIndex(int index);
}

enum TaskServiceDeviceType {
  addDevices(inputTypes: [List<Device>]),
  addDevice(inputTypes: [Device]),
  removeDevice(inputTypes: [Device]),
  syncDevices,
  updateDevice(inputTypes: [String, List<String>]),
  updateDeviceAppInfo(inputTypes: [String, ServerMessage]),
  connectDevice(inputTypes: [Device]),
  disconnectDevice(inputTypes: [Device]),
  addListener(inputTypes: [SendPort]),
  removeListener(inputTypes: [SendPort]),
  deviceByIndex(inputTypes: [int]),
  syncRunning,
  count,
  isEmpty,
  lastUpdate;

  final List<Type>? inputTypes;
  const TaskServiceDeviceType({this.inputTypes});
}

class TaskServiceDevice extends TaskBase<TaskServiceDeviceType> {
  TaskServiceDevice({required super.type, super.data});
}

class BasicTaskServiceDevice extends TaskBasic<TaskServiceDeviceType> {
  BasicTaskServiceDevice({
    required super.type,
    required super.taskId,
    required super.completerId,
    super.data,
  });

  factory BasicTaskServiceDevice.fromJson(Map<String, dynamic> map) {
    return BasicTaskServiceDevice(
      type: _parseTaskServiceDeviceType(map['type'] as String),
      taskId: map['taskId'] as String,
      completerId: map['completerId'] as int,
      data: map['data'],
    );
  }
}

TaskServiceDeviceType _parseTaskServiceDeviceType(String value) {
  return TaskServiceDeviceType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown TaskServiceDeviceType: $value'),
  );
}
