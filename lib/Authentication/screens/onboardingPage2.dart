import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Onboardingpage2 extends StatefulWidget {
  const Onboardingpage2({super.key});

  @override
  State<Onboardingpage2> createState() => _Onboardingpage2State();
}

class _Onboardingpage2State extends State<Onboardingpage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/Authentication/assets/images/onb1.png',
              width: 350,
              height: 350,
              fit: BoxFit.cover,
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(delay: 2000.ms, duration: 1400.ms),
            const SizedBox(height: 100),
            const Positioned(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: Text(
                  'Accelerate Your Service, Where Every Connection Counts!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
