import 'dart:async'; // Import the Timer class
import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_main_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';
import 'package:logger/logger.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key, required String uid});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String status = ''; // Initialize the status as an empty string
  final Logger logger = Logger();
  Timer? _timer; // Declare a Timer to run the fetch periodically

  Future<void> _fetchStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final fetchedStatus = await GetVerifiedServices().fetchStatus(user.uid);
      if (fetchedStatus != null && fetchedStatus != status) {
        setState(() {
          status = fetchedStatus;
        });
        logger.i('Status updated: $status');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Set up a Timer to fetch the status every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      _fetchStatus();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _buildScreenForStatus(status), // Build UI based on status
      ),
    );
  }

  // Conditionally build screen based on status
  Widget _buildScreenForStatus(String status) {
    switch (status) {
      case 'Pending':
        return _buildPendingScreen();
      case 'Verified':
        return _buildVerifiedScreen();
      case 'Rejected':
        return _buildRejectedScreen();
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  // Pending screen UI
  Widget _buildPendingScreen() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pending Icon
              const Icon(
                Icons.hourglass_top_rounded,  // Use an hourglass or similar icon to represent pending
                size: 120,
                color: Color(0xffFABC3F),  // Hex color #FFFE599
              ),
              const SizedBox(height: 20),
              // Pending Text
              const Text(
                'Your verification is',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'PENDING',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[800], // Optional: Yellow color to emphasize pending status
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Additional Message
              const Text(
                'Please wait while we review your submitted documents.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Button to Go Back
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AutomotiveMainProfile()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  backgroundColor: const Color(0xffFABC3F),  // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Verified screen UI
  Widget _buildVerifiedScreen() {
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AutomotiveMainProfile()),
                  );
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

  // Rejected screen UI
  Widget _buildRejectedScreen() {
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
