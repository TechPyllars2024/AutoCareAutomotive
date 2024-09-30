import 'package:flutter/material.dart';

class VerifiedVerificationScreen extends StatelessWidget {
  const VerifiedVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verification Status',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: const Color(0xff06D001),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Verified Icon
              const Icon(
                Icons.verified, // Verified icon
                color: Color(0xff06D001), // Icon color set to #fd9ead3
                size: 100, // Adjust icon size as needed
              ),
              const SizedBox(height: 20),

              // Verification Message
              const Text(
                'Your automotive shop has been successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Text color
                ),
              ),
              const Text(
                'VERIFIED',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                    color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle for additional details
              const Text(
                'Thank you for verifying your shop. You can now offer services on the platform.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54, // Subtitle text color
                ),
              ),

              const SizedBox(height: 32),

              // Done Button
              ElevatedButton(
                onPressed: () {
                  // Navigate back or perform any action
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  backgroundColor: const Color(0xff06D001), // Button color set to #fd9ead3
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Set the corner radius
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color for the button
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
