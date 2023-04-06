import 'package:flutter/material.dart';

abstract class AppButtonStyle {
  final mainColor = const Color(0xFF01B4E4);

  static final ButtonStyle linkButton = ButtonStyle(
    foregroundColor: MaterialStateProperty.all(const Color(0xFF01B4E4)),
    textStyle: MaterialStateProperty.all(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
  );
}
