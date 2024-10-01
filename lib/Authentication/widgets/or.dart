import 'package:flutter/material.dart';

class Or extends StatelessWidget {
  const Or({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: <Widget>[
        Expanded(
          child: Divider(
          color: Colors.grey.shade700, // Color of the divider
          thickness: 1, // Thickness of the divider
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
          'or',
          style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Divider(
          color: Colors.grey.shade700, // Color of the divider
          thickness: 1, // Thickness of the divider
          ),
        ),
      ],
    );
  }
}