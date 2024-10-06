import 'package:flutter/material.dart';

class Onboardingpage1 extends StatefulWidget {
  const Onboardingpage1({super.key});

  @override
  State<Onboardingpage1> createState() => _Onboardingpage1State();
}

class _Onboardingpage1State extends State<Onboardingpage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(

            child: Text('Onboarding Page 1')),
      ),
    );
  }
}
