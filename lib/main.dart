import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/utils/app_translates.dart';
import 'package:adb_manager/utils/tools_storage.dart';
import 'package:adb_manager/views/home/screen_home.dart';
import 'package:flutter/material.dart';

void main() {
  setupDi();
  di<ToolsStorage>().init();
  di<ServiceNotifications>().init();
  runApp(const MyApp());
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
