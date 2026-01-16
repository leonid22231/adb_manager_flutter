import 'dart:developer';
import 'dart:io';

import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/utils/app_translates.dart';
import 'package:adb_manager/utils/tools_storage.dart';
import 'package:adb_manager/views/home/screen_home.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main(List<String> args) async {
  log('Arguments: ${args.toString()}');
  setupDi();
  di<ToolsStorage>().init();
  di<ServiceNotifications>().init();

  if (!args.contains('--autostart')) {
    WidgetsFlutterBinding.ensureInitialized();
    setupLaunchAtStartup();
  }

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
