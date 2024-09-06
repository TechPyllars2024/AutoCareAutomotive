import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_edit_profile.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';

class AutomotiveProfile extends StatefulWidget {
  const AutomotiveProfile({super.key});

  @override
  State<AutomotiveProfile> createState() => _AutomotiveProfileState();
}

class _AutomotiveProfileState extends State<AutomotiveProfile> {
  final double coverHeight = 220;
  final double profileHeight = 130;

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AutomotiveEditProfile()),
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildTopSection(top),
          buildShopName(),
          buildButton(),
          //ServicesSection(),
        ],
      ),
    );
  }

  Widget buildButton() => WideButtons(
    onTap: editProfile,
    text: 'Edit Profile',
  );

  Widget buildShopName() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto Repair',
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
    color: Colors.grey,
    child: Image.network(
      'https://www.erieinsurance.com/-/media/images/blog/articlephotos/2018/rentalcarlg.ashx?h=529&w=1100&la=en&hash=B6312A1CFBB03D75789956B399BF6B91E7980061',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
  );

  Widget buildProfileImage() => CircleAvatar(
    radius: profileHeight / 2,
    backgroundColor: Colors.grey.shade800,
    backgroundImage: NetworkImage(
      'https://cdn.vectorstock.com/i/500p/57/48/auto-repair-service-logo-badge-emblem-template-vector-49765748.jpg',
    ),
  );
}
