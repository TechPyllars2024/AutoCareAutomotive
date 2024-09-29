import 'package:flutter/material.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/top_section.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/profile_details.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/services_carousel.dart';
import 'package:autocare_automotiveshops/ProfileManagement/widgets/feedback_section.dart';
import '../services/profile_service.dart';
import '../models/automotive_shop_profile_model.dart';
import '../widgets/button.dart'; // Assuming this is the button widget file
import 'automotive_edit_profile.dart';
import 'automotive_get_verified.dart';

class AutomotiveProfileScreen extends StatefulWidget {
  const AutomotiveProfileScreen({super.key});

  @override
  State<AutomotiveProfileScreen> createState() => _AutomotiveProfileScreenState();
}

class _AutomotiveProfileScreenState extends State<AutomotiveProfileScreen> {
  final ProfileService _profileService = ProfileService();
  AutomotiveProfileModel? profile;

  final double coverHeight = 220;
  final double profileHeight = 130;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final fetchedProfile = await _profileService.fetchProfileData();
    setState(() {
      profile = fetchedProfile;
    });
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AutomotiveEditProfile()),
    ).then((_) {
      // Reload profile data after returning from the edit profile screen
      _loadProfileData();
    });
  }

  void getVerified() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AutomotiveGetVerifiedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            TopSection(
              coverHeight: coverHeight,
              profileHeight: profileHeight,
              profile: profile,
            ),
            ProfileDetails(profile: profile),
            buildButton(),
            const SizedBox(height: 10),
            buildGetVerified(),
            const ServicesCarousel(),
            const FeedbackSection(),
          ],
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
}
