import 'dart:developer';
import 'dart:isolate';

import 'package:adb_manager/services/interface/service_adb_interface.dart';
import 'package:adb_manager/utils/task_queue.dart';

List<TaskServiceAdbType> serviceAdbIgnoreLogs = [
  TaskServiceAdbType.adbAvailable,
];

class ServiceAdbProxy extends ServiceAdbInterface {
  final SendPort backgroundSendPort;
  final TaskQueue taskQueue;
  //Получаем данные
  ReceivePort? _receivePort;

  ServiceAdbProxy(this.backgroundSendPort)
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
  Future<bool> get adbAvailable async {
    return taskQueue.addTask(
      TaskServiceAdb(type: TaskServiceAdbType.adbAvailable),
    );
  }

  @override
  void addListener(SendPort port) {
    taskQueue.addTask(
      TaskServiceAdb(type: TaskServiceAdbType.addListener, data: port),
    );
  }

  @override
  void removeListener(SendPort port) {
    taskQueue.addTask(
      TaskServiceAdb(type: TaskServiceAdbType.removeListener, data: port),
    );
  }

  void _handleResponse(dynamic data) {
    if (data is TaskResponse) {
      final response = data;
      if (serviceAdbIgnoreLogs.contains(
        taskQueue.getTaskById(response.taskId)?.type,
      )) {
        log('ServiceAdbProxy data[${data.toString()}]');
      }
      taskQueue.completeTask(response);
    }
  }

  void dispose() {
    _receivePort?.close();
    taskQueue.clearTasks();
  }
}
