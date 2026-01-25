import 'dart:isolate';

import 'package:adb_manager/utils/task_queue.dart';

abstract class ServiceAdbInterface {
  Future<bool> get adbAvailable;
  void addListener(SendPort port);
  void removeListener(SendPort port);
}

enum TaskServiceAdbType {
  addListener(inputTypes: [SendPort]),
  removeListener(inputTypes: [SendPort]),
  adbAvailable;

  final List<Type>? inputTypes;
  const TaskServiceAdbType({this.inputTypes});
}

class TaskServiceAdb extends TaskBase<TaskServiceAdbType> {
  TaskServiceAdb({required super.type, super.data});
}

class BasicTaskServiceAdb extends TaskBasic<TaskServiceAdbType> {
  BasicTaskServiceAdb({
    required super.type,
    required super.taskId,
    required super.completerId,
    super.data,
  });

  factory BasicTaskServiceAdb.fromJson(Map<String, dynamic> map) {
    return BasicTaskServiceAdb(
      type: _parseTaskServiceDeviceType(map['type'] as String),
      taskId: map['taskId'] as String,
      completerId: map['completerId'] as int,
      data: map['data'],
    );
  }
}

TaskServiceAdbType _parseTaskServiceDeviceType(String value) {
  return TaskServiceAdbType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown TaskServiceAdbType: $value'),
  );
}
