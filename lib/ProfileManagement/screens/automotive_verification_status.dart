import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerificationStatusScreen extends StatelessWidget {
  final String uid;

  VerificationStatusScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('verificationData')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No verification data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';

          return Center(
            child: Text(
              'Your verification status is $status',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}