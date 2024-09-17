import 'dart:io';

import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_edit_profile.dart';
import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_get_verified.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';

class AutomotiveProfile extends StatefulWidget {
  const AutomotiveProfile({super.key});

  @override
  State<AutomotiveProfile> createState() => _AutomotiveProfileState();
}

class _AutomotiveProfileState extends State<AutomotiveProfile> {
  File? _coverImage;
  File? _profileImage;

  final double coverHeight = 220;
  final double profileHeight = 130;


  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AutomotiveEditProfile()),
    );
  }

  void getVerified() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AutomotiveGetVerified()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black, // Ensures text is visible on AppBar
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildTopSection(top),
              buildShopName(),
              buildButton(),
              buildGetVerified(),
              ServicesCarousel(),
              FeedbackSection(),

              //ServicesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton() => WideButtons(
        onTap: editProfile,
        text: 'Edit Profile',
      );

  Widget buildGetVerified() => WideButtons(
        onTap: getVerified,
        text: 'Get Verified',
      );

  Widget buildShopName() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shop name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Location details',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),

              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Days of the Week',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),

              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    '00:00 AM - 00:00 PM',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildTopSection(double top) {
    double rating = 3;
    int numberOfRating = 33;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(),
        ),
        Positioned(
          left: 20,
          top: top,
          child: buildProfileImage(),
        ),
        Positioned(
          right: 20,
          top: coverHeight + 10,
          child: Row(
            children: [
              PannableRatingBar(
                rate: rating,
                items: List.generate(
                  5,
                  (index) => const RatingWidget(
                    selectedColor: Colors.orange,
                    unSelectedColor: Colors.grey,
                    child: Icon(
                      Icons.star,
                      size: 20,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
              SizedBox(width: 5),
              Text(
                '$numberOfRating ratings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey.shade700,
        width: double.infinity,
        height: coverHeight,
        child: _coverImage != null
            ? Image.file(
                _coverImage!,
                fit: BoxFit.cover,
              )
            : Container(),
      );

  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade600,
        child: _profileImage != null
            ? ClipOval(
                child: Image.file(
                  _profileImage!,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              )
            : const Icon(
                Icons.person,
                size: 100,
                color: Colors.white,
              ),
      );
}

Widget ServicesCarousel() => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(

                'Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
             Spacer(),
             IconButton(

                 onPressed: () {}, icon: Icon(Icons.add))
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: CarouselView(
            itemExtent: 280,
            children: List.generate(10, (int index) {
              return Container(
                child: Stack(
                  children: [
                    // ClipRRect to add curved corners and crop the bottom
                    Container(
                      margin: EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20), // Curve on the left
                          topRight: Radius.circular(20), // Curve on the right
                        ),
                        child: FractionallySizedBox(
                          heightFactor: 0.80,
                          // Crop to 75% height of the container
                          alignment: Alignment.topCenter,
                          // Align top portion
                          child: Image.network(
                            'https://soaphandcarwash.com/wp-content/uploads/2019/08/Soap-Hand-Car-Wash-13.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    // Overlay Text in the bottom 25% space
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50, // Allocating 25% space for text

                        padding: EdgeInsets.all(10),
                        child: Text(
                          textAlign: TextAlign.center,
                          'Car Wash',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                color: Colors.orangeAccent.shade100,
              );
            }),
          ),
        ),
      ],
    );

Widget FeedbackSection() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Feedbacks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
    ),
    Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Curved edges
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns the text to the left
          children: [
            Text('Paul Vincent Lerado', style: TextStyle(fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Text('I was impressed with the professionalism and efficiency of your team during my recent oil change and brake inspection. '
                  'However, the service took longer than expected, so providing more accurate time estimates would be helpful.'),
            ),
          ],
        ),
      ),
    ),
  ],
);





