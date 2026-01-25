import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/models/model_server_message.dart';
import 'package:adb_manager/services/interface/service_device_interface.dart';
import 'package:adb_manager/utils/task_queue.dart';

List<TaskServiceDeviceType> serviceDeviceIgnoreLogs = [
  TaskServiceDeviceType.syncRunning,
];

class ServiceDeviceProxy extends ServiceDeviceInterface {
  final SendPort backgroundSendPort;
  final TaskQueue taskQueue;
  //Получаем данные
  ReceivePort? _receivePort;

  ServiceDeviceProxy(this.backgroundSendPort)
    : taskQueue = TaskQueue(backgroundSendPort) {
    _initReceivePort();
  }

  void _initReceivePort() {
    _receivePort = ReceivePort();
    //Отправляем sendPort для ответа
    backgroundSendPort.send(_receivePort!.sendPort);
    //Получаем данные
    _receivePort!.listen(_handleResponse);
  }

  @override
  Future<void> addDevice(Device device) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.addDevice, data: device),
    );
  }

  @override
  Future<void> addDevices(List<Device> devices) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.addDevices, data: devices),
    );
  }

  @override
  void addListener(SendPort port) {
    taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.addListener, data: port),
    );
  }

  @override
  Future<void> connectDevice(Device device) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.connectDevice),
    );
  }

  @override
  Future<void> disconnectDevice(Device device) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.disconnectDevice),
    );
  }

  @override
  Future<void> removeDevice(Device device) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.removeDevice, data: device),
    );
  }

  @override
  void removeListener(SendPort port) {
    taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.removeListener, data: port),
    );
  }

  @override
  Future<void> syncDevices() {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.syncDevices),
    );
  }

  @override
  Future<bool> get syncRunning async {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.syncRunning),
    );
  }

  @override
  Future<void> updateDevice(String ip, List<String> ports) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.updateDevice),
    );
  }

  @override
  Future<void> updateDeviceAppInfo(String ip, ServerMessage message) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.updateDeviceAppInfo),
    );
  }

  @override
  Future<int> count() {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.count),
    );
  }

  @override
  Future<Device> deviceByIndex(int index) {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.deviceByIndex, data: index),
    );
  }

  @override
  Future<bool> isEmpty() {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.isEmpty),
    );
  }

  @override
  Future<DateTime?> get lastUpdate async {
    return taskQueue.addTask(
      TaskServiceDevice(type: TaskServiceDeviceType.lastUpdate),
    );
  }

  void _handleResponse(dynamic data) {
    if (data is TaskResponse) {
      final response = data;
      if (!serviceDeviceIgnoreLogs.contains(
        taskQueue.getTaskById(response.taskId)?.type,
      )) {
        log('ServiceDeviceProxy data[${data.toString()}]');
      }
      taskQueue.completeTask(response);
    }
  }

  void dispose() {
    _receivePort?.close();
    taskQueue.clearTasks();
  }
}
