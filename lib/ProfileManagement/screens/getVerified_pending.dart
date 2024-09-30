import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PendingVerificationScreen extends StatefulWidget {
  const PendingVerificationScreen({super.key});

  @override
  State<PendingVerificationScreen> createState() => _PendingVerificationScreenState();
}

class _PendingVerificationScreenState extends State<PendingVerificationScreen> {
late final String status;
final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> _fetchStatus() async {
    final user = _auth.currentUser;
    final fetchedStatus = await GetVerifiedServices().fetchStatus(user!.uid);
    setState(() {
      status = fetchedStatus!;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verification Status',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: const Color(0xffFABC3F),
      ),
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
                  Navigator.pop(context);  // Go back to the previous screen
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
}
