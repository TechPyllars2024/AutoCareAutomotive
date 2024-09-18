import 'package:flutter/material.dart';

class AcceptButton extends StatelessWidget {
  final VoidCallback? onTap; // Nullable onTap callback
  final String text;
  final Color color;
  final double padding;

  const AcceptButton({
    super.key,
    this.onTap, // Optional onTap callback
    required this.text,
    this.color = Colors.orange,
    this.padding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {}, // Use an empty function if onTap is null
      splashColor: Colors.black26,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: ShapeDecoration(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            color: color,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
