import 'package:flutter/material.dart';
import '../../main.dart';

class Utils {
  static showSnackBar(String? text, {Color backgroundColor = Colors.red, Duration duration = const Duration(seconds: 4)}) {
    if (text == null) return;

    final snackBar = SnackBar(
      content: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      duration: duration,
    );

    final messenger = messengerKey.currentState;
    if (messenger != null) {
      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }
}
