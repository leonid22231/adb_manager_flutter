import 'package:adb_manager/background_services/background_service_device.dart';
import 'package:adb_manager/services/service_tray.dart';
import 'package:adb_manager/services/service_window_manager.dart';
import 'package:adb_manager/views/utils/app.dart';

void setupAppDi() {
  App.di.registerLazySingleton<BackgroundServiceDevice>(
    () => BackgroundServiceDevice(),
  );
  App.di.registerLazySingleton<ServiceWindowManager>(
    () => ServiceWindowManager(),
  );
  App.di.registerLazySingleton<ServiceTray>(() => ServiceTray());
}
