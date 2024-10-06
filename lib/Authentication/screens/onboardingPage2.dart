import 'package:flutter/material.dart';

class Onboardingpage2 extends StatefulWidget {
  const Onboardingpage2({super.key});

  @override
  State<Onboardingpage2> createState() => _Onboardingpage2State();
}

class _Onboardingpage2State extends State<Onboardingpage2> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(

            child: Text('Onboarding Page 2')),
      ),
    );
  }
}
