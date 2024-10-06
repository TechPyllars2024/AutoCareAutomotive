import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage1.dart';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage2.dart';
import 'package:autocare_automotiveshops/Authentication/screens/onboardingPage3.dart';
import 'package:autocare_automotiveshops/Navigation Bar/navbar.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../ProfileManagement/screens/automotive_edit_profile.dart';



class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {

  PageController _controller = PageController();


  bool onLastPage = false;
  bool onFirstPage = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [ PageView(

          controller: _controller,

          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 3);
            });
          },
          children: [
            Onboardingpage1(),
            Onboardingpage2(),
            AutomotiveEditProfile(),
            Onboardingpage3(),

        
          ],
        ),
          Container(
            alignment: Alignment(0, 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  GestureDetector(
                      onTap: () {
                        _controller.previousPage(duration: Duration(microseconds: 500), curve: Curves.easeIn);
                      },
                      child: Text("previous")),

                  SmoothPageIndicator(controller: _controller, count: 4,
                    effect: ExpandingDotsEffect(
                    dotColor: Colors.grey,  // Inactive dot color
                    activeDotColor: Colors.orange.shade900,  // Active dot color
                    dotHeight: 8.0,
                    dotWidth: 8.0,
                  ),

                  ),

                  onLastPage?
                  GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Navbar()));
                      },

                      child: Text("")):
                  GestureDetector(
                      onTap: () {
                        _controller.nextPage(duration: Duration(microseconds: 500), curve: Curves.easeIn);
                      },

                      child: Text("next")),
                ],
              ))
    ]
      )
    );
  }
}
