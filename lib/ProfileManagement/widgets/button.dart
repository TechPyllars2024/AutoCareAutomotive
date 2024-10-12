import 'package:flutter/material.dart';

class WideButtons extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double padding;

  const WideButtons({
    super.key,
    required this.onTap,
    required this.text,
    this.padding = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size(400, 45),
          backgroundColor: Colors.deepOrange.shade700,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
