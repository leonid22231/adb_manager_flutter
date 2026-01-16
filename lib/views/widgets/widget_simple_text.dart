import 'package:flutter/material.dart';

class WidgetSimpleText extends StatelessWidget {
  final String text;
  final Color? textColor;
  const WidgetSimpleText({required this.text, this.textColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: textColor ?? Colors.black),
    );
  }
}
