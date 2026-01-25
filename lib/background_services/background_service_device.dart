import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:adb_manager/services/interface/service_adb_interface.dart';
import 'package:adb_manager/services/interface/service_device_interface.dart';
import 'package:adb_manager/services/proxies/service_adb_proxy.dart';
import 'package:adb_manager/services/proxies/service_device_proxy.dart';
import 'package:adb_manager/services/service_adb.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/utils/task_queue.dart';
import 'package:adb_manager/utils/tools_storage.dart';
import 'package:adb_manager/views/utils/app.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class BackgroundServiceDevice {
  late Isolate isolate;
  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  bool _isInit = false;
  Completer? completer;
  Future<void> init(RootIsolateToken rootToken) async {
    completer = Completer();
    _receivePort.listen(_receivePortListener);

    isolate = await Isolate.spawn(IsolateRunner.run, [
      rootToken,
      _receivePort.sendPort,
    ]);

    await completer!.future;
  }

  void _receivePortListener(dynamic data) {
    if (data is SendPort) {
      if (_isInit) {
        return;
      }
      _isInit = true;
      _sendPort = data;
      log('BackgroundServiceDevice is INIT');
    }
    if (data is ServiceReceived) {
      if (data.name == ServiceName.device) {
        ServiceDeviceProxy serviceDeviceProxy = ServiceDeviceProxy(
          data.sendPort,
        );

        App.di.registerLazySingleton<ServiceDeviceProxy>(
          () => serviceDeviceProxy,
        );
      } else if (data.name == ServiceName.adb) {
        ServiceAdbProxy serviceAdbProxy = ServiceAdbProxy(data.sendPort);
        App.di.registerLazySingleton<ServiceAdbProxy>(() => serviceAdbProxy);
      }
    }
    isInit();
  }

  void isInit() {
    if (completer == null) {
      return;
    }
    bool isInit =
        App.di.isRegistered<ServiceDeviceProxy>() &&
        App.di.isRegistered<ServiceAdbProxy>();

    if (isInit) {
      completer!.complete();
      completer = null;
    }
  }
}

class IsolateRunner {
  static late SendPort sendPort;
  static ReceivePort receivePort = ReceivePort('IsolateRunner');
  static late GetIt backgroundDi;
  static Completer? initCompleter;
  static late ReceivePort serviceDeviceReceivePort;
  static void run(List<Object> args) async {
    initCompleter = Completer();
    RootIsolateToken token = args[0] as RootIsolateToken;
    sendPort = args[1] as SendPort;

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    backgroundDi = GetIt.instance;
    initSendPort();
    setupDi();

    await initServices();

    await initCompleter!.future;

    SequentialTimer(
      interval: Duration(seconds: 1),
      task: () => onSecondTickMethod(port: sendPort),
    ).start();
  }

  static void initSendPort() {
    receivePort.listen(_receivePortListener);
    sendPort.send(receivePort.sendPort);
  }

  static void _receivePortListener(dynamic data) {}

  static void setupDi() {
    backgroundDi.registerLazySingleton<ToolsStorage>(() => ToolsStorage());
    backgroundDi.registerLazySingleton<ServiceAdb>(
      () => ServiceAdb(backgroundDi),
    );
    backgroundDi.registerLazySingleton<ServiceDevice>(
      () => ServiceDevice(backgroundDi),
    );
    backgroundDi.registerLazySingleton<ServiceNotifications>(
      () => ServiceNotifications(),
    );
  }

  static Future<void> initServices() async {
    ReceivePort serviceDevicePort = ReceivePort();
    ReceivePort serviceAdbPort = ReceivePort();
    serviceAdbPort.listen(ServiceAdbListen.listen);
    serviceDevicePort.listen(ServiceDeviceListen.listen);
    sendPort.send(
      ServiceReceived(
        name: ServiceName.device,
        sendPort: serviceDevicePort.sendPort,
      ),
    );
    sendPort.send(
      ServiceReceived(name: ServiceName.adb, sendPort: serviceAdbPort.sendPort),
    );
    await backgroundDi<ToolsStorage>().init();
    await backgroundDi<ServiceNotifications>().init();
    await backgroundDi<ServiceDevice>().init();

    initCompleter!.complete();
  }

  static Future<void> onSecondTickMethod({required SendPort port}) async {
    await backgroundDi<ServiceDevice>().syncDevices();
  }
}

class ServiceDeviceListen {
  static late SendPort sendPort;

  static void listen(dynamic data) async {
    if (data is SendPort) {
      sendPort = data;
    }

    if (data is Map<String, dynamic>) {
      try {
        BasicTaskServiceDevice task = BasicTaskServiceDevice.fromJson(data);
        if (!serviceDeviceIgnoreLogs.contains(task.type)) {
          log('ServiceDeviceListen data[$data]');
        }
        _handleTask(task);
      } catch (e) {
        //
        log('ServiceDeviceListen ERROR $e');
      }
    }
  }

  static void _handleTask(BasicTaskServiceDevice task) {
    switch (task.type) {
      case TaskServiceDeviceType.syncRunning:
        () async {
          final result =
              await IsolateRunner.backgroundDi<ServiceDevice>().syncRunning;
          sendPort.send(TaskResponse.success(task.taskId, result));
        }.call();
        break;
      case TaskServiceDeviceType.count:
        () async {
          final result = await IsolateRunner.backgroundDi<ServiceDevice>()
              .count();
          sendPort.send(TaskResponse.success(task.taskId, result));
        }.call();
        break;
      case TaskServiceDeviceType.isEmpty:
        () async {
          final result = await IsolateRunner.backgroundDi<ServiceDevice>()
              .isEmpty();

          sendPort.send(TaskResponse.success(task.taskId, result));
        }.call();
        break;
      case TaskServiceDeviceType.deviceByIndex:
        () async {
          final result = await IsolateRunner.backgroundDi<ServiceDevice>()
              .deviceByIndex(task.data);
          sendPort.send(TaskResponse.success(task.taskId, result));
        }.call();
        break;
      case TaskServiceDeviceType.addDevice:
        () async {
          await IsolateRunner.backgroundDi<ServiceDevice>().addDevice(
            task.data,
          );
          sendPort.send(TaskResponse.success(task.taskId, null));
        }.call();
        break;
      case TaskServiceDeviceType.addDevices:
        () async {
          await IsolateRunner.backgroundDi<ServiceDevice>().addDevices(
            task.data,
          );
          sendPort.send(TaskResponse.success(task.taskId, null));
        }.call();
        break;
      case TaskServiceDeviceType.removeDevice:
        () async {
          await IsolateRunner.backgroundDi<ServiceDevice>().removeDevice(
            task.data,
          );
          sendPort.send(TaskResponse.success(task.taskId, null));
        }.call();
        break;
      case TaskServiceDeviceType.addListener:
        () async {
          IsolateRunner.backgroundDi<ServiceDevice>().addListener(task.data);
          sendPort.send(TaskResponse.success(task.taskId, null));
        }.call();
        break;
      case TaskServiceDeviceType.removeListener:
        () async {
          IsolateRunner.backgroundDi<ServiceDevice>().removeListener(task.data);
          sendPort.send(TaskResponse.success(task.taskId, null));
        }.call();
        break;
      default:
        () {
          TaskResponse response = TaskResponse.error(task.taskId, 'Error');
          sendPort.send(response);
        }.call();
    }
  }
}

class ServiceAdbListen {
  static late SendPort sendPort;

  static void listen(dynamic data) {
    if (data is SendPort) {
      sendPort = data;
    }

    if (data is Map<String, dynamic>) {
      try {
        BasicTaskServiceAdb task = BasicTaskServiceAdb.fromJson(data);
        if (!serviceAdbIgnoreLogs.contains(task.type)) {
          log('ServiceAdbListen data[$data]');
        }
        _handleTask(task);
      } catch (e) {
        //
        log('ServiceAdbListen ERROR $e');
      }
    }
  }

  static void _handleTask(BasicTaskServiceAdb task) {
    switch (task.type) {
      case TaskServiceAdbType.adbAvailable:
        () async {
          final result =
              await IsolateRunner.backgroundDi<ServiceAdb>().adbAvailable;
          TaskResponse response = TaskResponse.success(task.taskId, result);
          sendPort.send(response);
        }.call();
        break;
      case TaskServiceAdbType.addListener:
        () async {
          IsolateRunner.backgroundDi<ServiceAdb>().addListener(task.data);
          sendPort.send(TaskResponse.success(task.taskId, null));
        }.call();
        break;
      case TaskServiceAdbType.removeListener:
        () async {
          IsolateRunner.backgroundDi<ServiceAdb>().removeListener(task.data);
          sendPort.send(TaskResponse.success(task.taskId, null));
        }.call();
        break;
      default:
        () {
          TaskResponse response = TaskResponse.error(task.taskId, 'Error');
          sendPort.send(response);
        }.call();
    }
  }
}

enum ServiceName { device, adb }

class ServiceReceived {
  ServiceName name;
  SendPort sendPort;
  ServiceReceived({required this.name, required this.sendPort});
}

class SequentialTimer {
  Timer? _timer;
  bool _isRunning = false;
  final Duration interval;
  final Future<void> Function() task;

  SequentialTimer({required this.interval, required this.task});

  void start() {
    if (!_isRunning) {
      _isRunning = true;
      _scheduleNextTick();
    }
  }

  void _scheduleNextTick() async {
    await task();

    if (_isRunning) {
      await Future.delayed(interval);
      _scheduleNextTick();
    }
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
  }
}
