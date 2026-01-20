// ignore_for_file: unused_field

import 'dart:developer';
import 'dart:io';

import 'package:adb_manager/app/di.dart';
import 'package:adb_manager/services/service_window_manager.dart';
import 'package:system_tray/system_tray.dart';

class ServiceTray {
  bool _isInit = false;

  late AppWindow _window;
  late SystemTray _systemTray;

  final List<MenuItemLabel> _menuIsVisible = [
    MenuItemLabel(
      label: 'Hide',
      onClicked: (menuItem) => di<ServiceWindowManager>().hide(),
    ),
    MenuItemLabel(
      label: 'Close Program',
      onClicked: (menuItem) => di<ServiceWindowManager>().close(),
    ),
  ];

  final List<MenuItemLabel> _menuIsNotVisible = [
    MenuItemLabel(
      label: 'Show',
      onClicked: (menuItem) => di<ServiceWindowManager>().show(),
    ),
    MenuItemLabel(
      label: 'Close Program',
      onClicked: (menuItem) => di<ServiceWindowManager>().close(),
    ),
  ];

  Future<void> init() async {
    if (_isInit) {
      return;
    }
    try {
      await initSystemTray();
      _isInit = true;
    } catch (e) {
      log('TRAY ${e.toString()}');
    }
  }

  Future<void> setMenu({required List<MenuItemLabel> menuList}) async {
    final Menu menu = Menu();

    await menu.buildFrom(menuList);

    await _systemTray.setContextMenu(menu);
  }

  Future<void> show() async {
    await _systemTray.popUpContextMenu();
  }

  Future<void> initSystemTray() async {
    String path = Platform.isWindows
        ? 'assets/app_icon.ico'
        : 'assets/app_icon.png';

    _window = AppWindow();
    _systemTray = SystemTray();

    await _systemTray.initSystemTray(title: "system tray", iconPath: path);

    _systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        di<ServiceWindowManager>().switchVisible();
      } else if (eventName == kSystemTrayEventRightClick) {
        bool isVisible = await di<ServiceWindowManager>().isVisible();

        if (isVisible) {
          await setMenu(menuList: _menuIsVisible);
          await show();
        } else {
          await setMenu(menuList: _menuIsNotVisible);
          await show();
        }
      }
    });
  }
}
