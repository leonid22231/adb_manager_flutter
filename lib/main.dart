import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/background_services/background_service_device.dart';
import 'package:adb_manager/services/service_tray.dart';
import 'package:adb_manager/services/service_window_manager.dart';
import 'package:adb_manager/utils/app_translates.dart';
import 'package:adb_manager/views/home/screen_home.dart';
import 'package:adb_manager/views/utils/app.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main(List<String> args) async {
  log('Arguments: ${args.toString()}');
  bool isAutoStart = false;
  isAutoStart = !args.contains('--autostart');

  const bool isRunBuilder =
      String.fromEnvironment('AUTOSTART', defaultValue: 'false') == 'true';

  isAutoStart = isRunBuilder;

  setupAppDi();

  WidgetsFlutterBinding.ensureInitialized();
  final rootToken = RootIsolateToken.instance!;

  await App.di<BackgroundServiceDevice>().init(rootToken);

  await App.di<ServiceWindowManager>().init(isAutoStart: isAutoStart);

  setupLaunchAtStartup();

  App.di<ServiceTray>().init();

  runApp(const MyApp());
}


void setupLaunchAtStartup() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    packageName: 'com.lyadev.adb_manager',
    args: ['--autostart'],
  );

  await launchAtStartup.enable();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTranslates.appName.toString(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: ScreenHome(),
    );
  }
}
