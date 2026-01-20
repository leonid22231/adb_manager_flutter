import 'package:adb_manager/background_services/background_service_device.dart';
import 'package:adb_manager/services/service_adb.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/services/service_tray.dart';
import 'package:adb_manager/services/service_window_manager.dart';
import 'package:adb_manager/utils/tools_storage.dart';
import 'package:get_it/get_it.dart';

GetIt di = GetIt.instance;

void setupDi() {
  if (di.isRegistered<BackgroundServiceDevice>()) {
    di.unregister<BackgroundServiceDevice>();
  }
  di.registerLazySingleton<BackgroundServiceDevice>(
    () => BackgroundServiceDevice(),
  );
  //
  if (di.isRegistered<ToolsStorage>()) {
    di.unregister<ToolsStorage>();
  }
  di.registerLazySingleton<ToolsStorage>(() => ToolsStorage());
  //
  if (di.isRegistered<ServiceWindowManager>()) {
    di.unregister<ServiceWindowManager>();
  }
  di.registerLazySingleton<ServiceWindowManager>(() => ServiceWindowManager());
  //
  if (di.isRegistered<ServiceTray>()) {
    di.unregister<ServiceTray>();
  }
  di.registerLazySingleton<ServiceTray>(() => ServiceTray());
  //
  if (di.isRegistered<ServiceAdb>()) {
    di.unregister<ServiceAdb>();
  }
  di.registerLazySingleton<ServiceAdb>(() => ServiceAdb());
  //
  if (di.isRegistered<ServiceDevice>()) {
    di.unregister<ServiceDevice>();
  }
  di.registerLazySingleton<ServiceDevice>(() => ServiceDevice());
  //
  if (di.isRegistered<ServiceNotifications>()) {
    di.unregister<ServiceNotifications>();
  }
  di.registerLazySingleton<ServiceNotifications>(() => ServiceNotifications());
}
