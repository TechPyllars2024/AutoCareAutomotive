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
      body: const Center(
        child: Text(
          'Your verification request is pending',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}