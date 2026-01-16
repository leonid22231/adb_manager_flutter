import 'package:adb_manager/views/widgets/widget_button.dart';
import 'package:flutter/material.dart';

class ScreenWidgets extends StatefulWidget {
  const ScreenWidgets({super.key});

  static Widget overlay(BuildContext context, {required Widget child}) {
    Widget buildButton() {
      return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ScreenWidgets()));
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
      appBar: AppBar(
        title: Text('Widgets test'.toUpperCase()),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
        child: Column(
          children: [
            buildSection('Buttons', [
              WidgetButton(
                title: 'Test',
                onTap: () {},
              )
            ])
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
            Container(
              height: 1,
              color: borderColor,
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 10),
              child: Column(
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
