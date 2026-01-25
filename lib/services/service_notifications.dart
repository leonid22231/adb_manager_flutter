import 'dart:math';

import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/models/model_notification.dart';
import 'package:adb_manager/utils/app_translates.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

class ServiceNotifications {
  static String guid = Uuid().v4();
  bool _isInit = false;

  static NotificationDetails defaultDetails = NotificationDetails(
    windows: WindowsNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final List<Notification> _history = [];

  Future<void> init() async {
    if (_isInit) return;
    final WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
          appName: AppTranslates.appName.toString(),
          appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
          guid: guid,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(windows: initializationSettingsWindows);

    await _plugin.initialize(initializationSettings);
    _isInit = true;
  }

  void saveNotification(Notification notification) {
    _history.add(notification);
  }

  void sendTestPush() async {
    Notification notification = Notification(
      title: 'Test title',
      body: 'Test body',
    );

    notification.show(showID: true);
  }

  void sendDeviceOnlineNotification(Device device) {
    String title;
    String body;
    if (device.deviceStatus == DeviceStatus.online) {
      title = AppTranslates.notificationDeviceOnlineTitle.toString();
      body = AppTranslates.notificationDeviceOnlineBody.toStringValues([
        AppTranslatesValue(name: 'name', value: device.name),
      ]);
    } else if (device.deviceStatus == DeviceStatus.offline) {
      title = AppTranslates.notificationDeviceOfflineTitle.toString();
      body = AppTranslates.notificationDeviceOfflineBody.toStringValues([
        AppTranslatesValue(name: 'name', value: device.name),
      ]);
    } else {
      title = AppTranslates.notificationDeviceUnstableTitle.toString();
      body = AppTranslates.notificationDeviceUnstableBody.toStringValues([
        AppTranslatesValue(name: 'name', value: device.name),
      ]);
    }

    Notification notification = Notification(title: title, body: body);

    String? subtitle = device.name != device.deviceIp
        ? device.getAddressMaybeNotPort()
        : null;

    notification.show(
      details: NotificationDetails(
        windows: WindowsNotificationDetails(subtitle: subtitle),
      ),
    );
  }

  void sendDeviceAdbNotConnect(Device device) {
    Notification notification = Notification(
      title: AppTranslates.notificationDeviceAdbNotConnectTitle.toString(),
      body: AppTranslates.notificationDeviceAdbNotConnectBody.toString(),
    );

    String? subtitle = device.name != device.deviceIp
        ? device.getAddressMaybeNotPort()
        : null;

    notification.show(
      details: NotificationDetails(
        windows: WindowsNotificationDetails(subtitle: subtitle),
      ),
    );
  }

  int newNotificationId() {
    Random random = Random();
    int tempId = 10000 + random.nextInt(90000);
    bool isExist = _history.map((e) => e.id).contains(tempId);
    if (isExist) {
      return newNotificationId();
    }
    return tempId;
  }

  FlutterLocalNotificationsPlugin get pluginInstance => _plugin;
}
