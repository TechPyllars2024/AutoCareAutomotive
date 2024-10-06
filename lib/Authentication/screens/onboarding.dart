import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage1.dart';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage2.dart';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage3.dart';
import 'package:autocare_automotiveshops/Navigation%20Bar/navbar.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../ProfileManagement/screens/automotive_edit_profile.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int currentPageIndex = 0; // Track the current page index

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        currentPageIndex = _controller.page?.round() ?? 0; // Update the current page index
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index; // Update the current page index
              });
            },
            children: const [
              Onboardingpage1(),
              Onboardingpage2(),
              AutomotiveEditProfile(),
              Onboardingpage3(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                currentPageIndex == 0
                    ? const Text("      ") // Don't show "pre" if on first page
                    : GestureDetector(
                  onTap: () {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                  },
                  child: const Icon(Icons.navigate_before),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.grey, // Inactive dot color
                    activeDotColor: Colors.orange.shade900, // Active dot color
                    dotHeight: 8.0,
                    dotWidth: 8.0,
                  ),
                ),
                (currentPageIndex == 2 || currentPageIndex == 3)
                    ? const Text("") // Don't show the next icon on the third page or the last page
                    : GestureDetector(
                  onTap: () {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                  },
                  child: const Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
