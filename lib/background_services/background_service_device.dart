import 'dart:async';
import 'dart:isolate';

import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/main.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class BackgroundServiceDevice {
  late Isolate isolate;
  final ReceivePort _receivePort = ReceivePort();

  Future<void> init(RootIsolateToken rootToken) async {
    isolate = await Isolate.spawn(IsolateRunner.run, [
      rootToken,
      _receivePort.sendPort,
    ]);
  }
}

class IsolateRunner {
  static void run(List<Object> list) async {  
    RootIsolateToken token = list[0] as RootIsolateToken;
    SendPort port = list[1] as SendPort;

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    di = GetIt.instance;

    await init();
    SequentialTimer(
      interval: Duration(seconds: 1),
      task: () => onSecondTickMethod(port: port),
    ).start();
  }

  static Future<void> onSecondTickMethod({required SendPort port}) async {
    await di<ServiceDevice>().syncDevices();
  }
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
