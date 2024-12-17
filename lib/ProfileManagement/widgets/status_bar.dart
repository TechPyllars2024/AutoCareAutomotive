import 'package:flutter/material.dart';

class ServiceStatusAlertBox extends StatelessWidget {
  final bool isVerified;

  const ServiceStatusAlertBox({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        elevation: 15,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.orange.shade900,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange.shade900),
              const SizedBox(width: 8.0),
              const Expanded(
                child: Text(
                  'Your services are currently not visible on your customers. It will be displayed again if you will pay the autocare fee.',
                  style: TextStyle(
                    fontSize: 13,
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