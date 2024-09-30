import 'package:flutter/material.dart';

class RejectedVerificationScreen extends StatelessWidget {
  const RejectedVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verification Status',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: const Color(0xffE72929), // Use the requested color for AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rejected Icon
              const Icon(
                Icons.cancel_rounded,  // Use a "cancel" or "error" icon to represent rejection
                size: 120,
                color: Color(0xffE72929),  // Hex color #f4cccc
              ),
              const SizedBox(height: 20),

              // Rejected Text
              const Text(
                'Your verification has been',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'REJECTED',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Optional: Red color to emphasize rejection
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Additional Message
              const Text(
                'Unfortunately, your submitted documents did not meet our requirements.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Please try again or contact support.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Button to Go Back
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  // Go back to the previous screen
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  backgroundColor: const Color(0xffE72929),  // Button color matching the rejected status
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,  // Button text color
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
