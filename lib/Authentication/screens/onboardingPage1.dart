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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/Authentication/assets/images/onboard1.png',
              width: 400,
              height: 400,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Text('Rev Up Your Business: Connect with Clients Effortlessly!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Customize your text style
                textAlign: TextAlign.center,),
            ),
          ]
        ), // Fixed closing parenthesis
      ),
    );
  }
}
