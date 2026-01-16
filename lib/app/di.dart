import 'package:adb_manager/services/service_adb.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/utils/tools_storage.dart';
import 'package:get_it/get_it.dart';

GetIt di = GetIt.instance;

void setupDi() {
  di.registerLazySingleton<ToolsStorage>(() => ToolsStorage());
  di.registerLazySingleton<ServiceAdb>(() => ServiceAdb());
  di.registerLazySingleton<ServiceDevice>(() => ServiceDevice());
  di.registerLazySingleton<ServiceNotifications>(() => ServiceNotifications());
}
