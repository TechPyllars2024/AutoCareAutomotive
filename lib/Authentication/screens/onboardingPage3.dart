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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/Authentication/assets/images/autocareLogo.png',
          ),
          const SizedBox(height: 80),
          const Text(
            'You are all set.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          RichText(
            text: const TextSpan(
              text: 'Welcome to Auto',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: 'Care',
                  style: TextStyle(color: Color(0xFFe65100)),
                ),
                TextSpan(
                  text: '!',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
