import 'package:flutter/material.dart';

import '../../Navigation Bar/navbar.dart';

class Onboardingpage3 extends StatefulWidget {
  const Onboardingpage3({super.key});

  @override
  State<Onboardingpage3> createState() => _Onboardingpage3State();
}

class _Onboardingpage3State extends State<Onboardingpage3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'All Done!',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Navbar()));
              },
              child: Text(
                "Done",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.orange.shade900,
                 // decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
