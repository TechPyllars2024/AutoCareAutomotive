import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage1.dart';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage2.dart';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage3.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../ProfileManagement/screens/automotive_complete_profile.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        currentPageIndex = _controller.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            children: const [
              Onboardingpage1(),
              Onboardingpage2(),
              AutomotiveCompleteProfileScreen(),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  currentPageIndex == 0
                      ? const Text("       ")
                      : GestureDetector(
                          onTap: () {
                            _controller.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                          child: const Icon(
                            Icons.navigate_before,
                            size: 30,
                          ),
                        ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 4,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.black54,
                      activeDotColor: Colors.orange.shade300,
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                    ),
                  ),
                  (currentPageIndex == 2 || currentPageIndex == 3)
                      ? const Text("        ")
                      : GestureDetector(
                          onTap: () {
                            _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                          child: const Icon(
                            Icons.navigate_next,
                            size: 30,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
