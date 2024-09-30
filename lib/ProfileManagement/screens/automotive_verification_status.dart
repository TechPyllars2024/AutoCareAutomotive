import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:autocare_automotiveshops/ProfileManagement/services/get_verified_services.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  late String status; // Set initial status to 'Pending' after submission
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _fetchStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final fetchedStatus = await GetVerifiedServices().fetchStatus(user.uid);
      setState(() {
        status = fetchedStatus!; // Update the status based on admin decision
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStatus(); // Fetch status after submission and update if necessary
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: const Color(0xffFABC3F),
      ),
      body: Center(
        child: _buildScreenForStatus(status), // Always use the current status to build the screen
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
        return const Text('Unknown Status');
    }
  }

  // Pending screen UI
  Widget _buildPendingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.hourglass_top_rounded, size: 120, color: Color(0xFFFFE599)),
        const SizedBox(height: 20),
        const Text('Your verification is', style: TextStyle(fontSize: 20)),
        const Text('PENDING', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.yellow)),
        const SizedBox(height: 10),
        const Text('Please wait while we review your submitted documents.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
      ],
    );
  }

  // Verified screen UI
  Widget _buildVerifiedScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_rounded, size: 120, color: Color(0xFFFD9EAD)),
        const SizedBox(height: 20),
        const Text('Congratulations!', style: TextStyle(fontSize: 20)),
        const Text('VERIFIED', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 10),
        const Text('Your account has been successfully verified.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
      ],
    );
  }

  // Rejected screen UI
  Widget _buildRejectedScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cancel_rounded, size: 120, color: Color(0xFFF4CCCC)),
        const SizedBox(height: 20),
        const Text('Sorry, your verification was', style: TextStyle(fontSize: 20)),
        const Text('REJECTED', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 10),
        const Text('Please contact support for more information.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
      ],
    );
  }
}
