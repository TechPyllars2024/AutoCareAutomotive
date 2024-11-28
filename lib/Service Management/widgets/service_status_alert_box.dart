import 'package:flutter/material.dart';

class ServiceStatusAlertBox extends StatelessWidget {
  final bool isVerified;

  const ServiceStatusAlertBox({Key? key, required this.isVerified}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.orange.shade900,
              width: 2.0,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange.shade900),
              const SizedBox(width: 8.0),
              const Expanded(
                child: Text(
                  'Your services will be displayed if you are verified.',
                  style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}