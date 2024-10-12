import 'package:flutter/material.dart';

class ServiceStatusAlertBox extends StatelessWidget {
  final bool isVerified;

  const ServiceStatusAlertBox({Key? key, required this.isVerified}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade200,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Text(
          'Your services will be displayed if you are verified.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}