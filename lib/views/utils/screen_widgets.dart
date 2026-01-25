import 'package:adb_manager/models/model_device.dart';
import 'package:adb_manager/services/service_device.dart';
import 'package:adb_manager/services/service_notifications.dart';
import 'package:adb_manager/views/utils/app.dart';
import 'package:adb_manager/views/widgets/widget_button.dart';
import 'package:flutter/material.dart';

class ScreenWidgets extends StatefulWidget {
  const ScreenWidgets({super.key});

  static Widget overlay(BuildContext context, {required Widget child}) {
    Widget buildButton() {
      return GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => ScreenWidgets()));
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.grey.shade200,
          ),
          child: Icon(Icons.bug_report),
        ),
      );
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: buildButton(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _ScreenWidgets();
}

class _ScreenWidgets extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Widgets test'.toUpperCase())),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection('Buttons', [
              WidgetButton(
                title: 'Send test push',
                onTap: App.di<ServiceNotifications>().sendTestPush,
              ),
              SizedBox(height: 10),
              WidgetButton(
                title: 'Send test push device online',
                onTap: () {
                  App.di<ServiceNotifications>().sendDeviceOnlineNotification(
                    Device(
                      name: 'Девайс 123',
                      deviceIp: '192.168.0.1',
                      devicePort: '5555',
                    ),
                  );
                },
              ),
            ]),
            SizedBox(height: 10),
            buildSection('Settings', [
              WidgetButton(
                title: 'Clear App',
                onTap: App.di<ServiceDevice>().clear,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children, {Color? color}) {
    Color borderColor = color ?? Colors.blue.shade400;
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(border: BoxBorder.all(color: borderColor)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title.toUpperCase()),
            SizedBox(height: 2),
            Container(height: 1, color: borderColor),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 10),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }
}
