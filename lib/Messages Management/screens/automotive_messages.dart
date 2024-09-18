import 'package:flutter/material.dart';

class AutomotiveMessagesScreen extends StatefulWidget {
  const AutomotiveMessagesScreen({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveMessagesScreen> createState() => _AutomotiveMessagesScreenState();
}

class _AutomotiveMessagesScreenState extends State<AutomotiveMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
    );
  }
}
//
