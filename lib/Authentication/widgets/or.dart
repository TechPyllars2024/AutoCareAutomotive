import 'package:flutter/material.dart';

class Or extends StatelessWidget {
  const Or({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(
          child: Divider(
          color: Colors.black, // Color of the divider
          thickness: 1, // Thickness of the divider
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
          'OR',
          style: TextStyle(color: Colors.black),
          ),
        ),
        Expanded(
          child: Divider(
          color: Colors.black, // Color of the divider
          thickness: 1, // Thickness of the divider
          ),
        ),
      ],
    );
  }
}