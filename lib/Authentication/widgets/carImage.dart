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
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
