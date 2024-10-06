import 'package:flutter/material.dart';
import 'dart:async';
import '../../Navigation Bar/navbar.dart';

class Onboardingpage3 extends StatefulWidget {
  const Onboardingpage3({super.key});

  @override
  State<Onboardingpage3> createState() => _Onboardingpage3State();
}

class _Onboardingpage3State extends State<Onboardingpage3> {
  @override
  void initState() {
    super.initState();
    // Navigate to Navbar after 5 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Navbar()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'You are all set!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
