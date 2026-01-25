import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:adb_manager/services/interface/service_adb_interface.dart';
import 'package:adb_manager/services/interface/service_device_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class TaskQueue {
  final SendPort sendPort;
  TaskQueue(this.sendPort);

  final Map<String, Completer<dynamic>> _pendingTasks = {};
  final Map<String, TaskBase> _activeTasks = {};

  Future<T> addTask<T>(TaskBase task) async {
    if (!_checkTask(task)) {
      debugPrintStack(label: 'Task[${task.type}] ERROR ARGS', maxFrames: 2);
      return null as T;
    }

    final completer = Completer<T>();
    task.completer = completer;
    _pendingTasks[task.taskId] = completer;
    _activeTasks[task.taskId] = task;

    _sendToBackground(task);

    return completer.future;
  }

  bool _checkTask(TaskBase taskBase) {
    TaskType? taskType = TaskType.fromEnum(taskBase.type);
    if (taskType == null) {
      log('Task[${taskBase.type.name}] is not supported');
      return false;
    }

    int dataSize = taskType.inputTypes?.length ?? 0;
    if (dataSize == 0) return true;

    if (dataSize > 1) {
      if (taskBase.data is List) {
        if (dataSize == (taskBase.data as List).length) {
          if (_compareTypesUnordered(taskType.inputTypes!, taskBase.data)) {
            return true;
          }
        }
      } else {
        log('Task[${taskBase.type.name}] required args[$dataSize]');
        return false;
      }
    } else if (dataSize == 1 && taskBase.data != null) {
      if (_compareTypesUnordered(taskType.inputTypes!, [taskBase.data])) {
        return true;
      }
    }
    return false;
  }

  bool _compareTypesUnordered(List<Type> expectedTypes, List actualList) {
    if (expectedTypes.length != actualList.length) return false;

    for (var item in actualList) {
      bool isAllowed = false;
      for (var expectedType in expectedTypes) {
        if (item.runtimeType == expectedType ||
            item.runtimeType.toString().replaceFirst('_', '') ==
                expectedType.toString()) {
          isAllowed = true;
          break;
        }
      }
      if (!isAllowed) {
        log('❌ ${item.runtimeType} not found');
        return false;
      }
    }
    return true;
  }

  void completeTask(TaskResponse response) {
    final completer = _pendingTasks.remove(response.taskId);
    _activeTasks.remove(response.taskId); // ✅ Удаляем из активных!
    if (completer != null) {
      if (response.success) {
        completer.complete(response.data);
      } else {
        completer.completeError(Exception(response.error));
      }
    } else {
      log('Completer is null ');
    }
  }

  TaskBase? getTaskById(String id) {
    return _activeTasks[id];
  }

  void _sendToBackground(TaskBase task) {
    sendPort.send(task.toJson());
  }

  void clearTasks() {
    _pendingTasks.clear();
    _activeTasks.clear(); // ✅ Очищаем активные задачи
  }
}

final uuid = Uuid();

abstract class TaskBase<E extends Enum> {
  final E type;
  final dynamic data;
  Completer<dynamic>? completer;
  final String taskId;

  TaskBase({required this.type, this.data})
    : taskId =
          '${type.name}_${DateTime.now().millisecondsSinceEpoch}_${uuid.v4()}';

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'data': data,
    'taskId': taskId,
    'completerId': completer.hashCode,
  };
}

abstract class TaskBasic<E extends Enum> {
  final E type;
  final dynamic data;
  final String taskId;
  final int completerId;

  TaskBasic({
    required this.type,
    required this.taskId,
    required this.completerId,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
    'taskId': taskId,
    'completerId': completerId,
  };

  factory TaskBasic.fromJson(Map<String, dynamic> map) {
    throw UnimplementedError('fromJson должен быть переопределен в наследнике');
  }
}

class TaskType {
  final List<Type>? inputTypes;
  final String name;

  const TaskType({this.inputTypes, required this.name});

  static TaskType? fromEnum(Enum taskType) {
    if (taskType is TaskServiceDeviceType) {
      return TaskType(inputTypes: taskType.inputTypes, name: taskType.name);
    }
    if (taskType is TaskServiceAdbType) {
      return TaskType(inputTypes: taskType.inputTypes, name: taskType.name);
    }
    return null;
  }
}

class TaskResponse {
  final String taskId;
  final dynamic data;
  final bool success;
  final String? error;

  TaskResponse.success(this.taskId, this.data) : success = true, error = null;

  TaskResponse.error(this.taskId, this.error) : data = null, success = false;

  @override
  String toString() {
    if (success) {
      return 'TaskResponse[taskId: $taskId, success: true, data: $data]';
    } else {
      return 'TaskResponse[taskId: $taskId, success: false, error: $error]';
    }
  }
}
