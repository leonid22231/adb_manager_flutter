import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class ServiceWindowManager {
  bool isAutoStart = false;

  Future<void> init({bool isAutoStart = false}) async {
    Completer completer = Completer();
    try {
      windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(769, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        this.isAutoStart = isAutoStart;
        windowManager.setPreventClose(true);
        windowManager.addListener(MyWindowListener());
        completer.complete();
      });
    } catch (e) {
      log('Error ${e.toString()}');
      completer.complete();
    }
    await completer.future;
  }

  void hideIfAutoStart() {
    if (isAutoStart) {
      WidgetsBinding.instance.addPostFrameCallback((duration) async {
        await Future.delayed(Duration(seconds: 5));
        hide();
      });
    }
  }

  Future<void> switchVisible() async {
    bool isVisible = await windowManager.isVisible();

    if (!isVisible) {
      await show();
    } else {
      await hide();
    }
  }

  Future<bool> isVisible() async {
    bool isVisible = await windowManager.isVisible();
    return isVisible;
  }

  Future<void> show() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> hide() async {
    await windowManager.hide();
  }

  Future<void> close() async {
    await windowManager.close();
  }
}

class MyWindowListener extends WindowListener {
  @override
  void onWindowClose() {
    windowManager.hide();
  }

  @override
  void onWindowMinimize() {
    windowManager.hide();
  }
}
