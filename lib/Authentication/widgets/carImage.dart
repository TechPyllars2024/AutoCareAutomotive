import 'package:flutter/material.dart';

class CarImageWidget extends StatelessWidget {
  final String imagePath;

  const CarImageWidget({
    super.key,
    required this.imagePath,
  });

@override
Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      height: 180,
    );
  }
}